#include "file_abstraction.hpp"

using namespace std;

#if defined(HAVE_LIBZIP)
#if defined(__GNUC__)
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wshadow"
#endif
#include <zip.h>
#if defined(__GNUC__)
#pragma GCC diagnostic pop
#endif
#endif

#if defined(HAVE_SSTREAM)
#include <sstream>
typedef std::istringstream myistringstream;
#elif defined(HAVE_CLASS_STRSTREAM)
#if defined(HAVE_STRSTREAM)
#include <strstream>
#else
#include <strstream.h>
#endif
typedef std::strstream myistringstream;
#else
#error "No suitable string stream class found."
#endif

namespace {
// Owns the buffer.
class bufferstream : public myistringstream {
    char *buf;

  public:
    bufferstream(char *_buf, size_t len) : buf(_buf) {
        rdbuf()->pubsetbuf(buf, len);
    }

    virtual ~bufferstream() { delete buf; }
};
} // namespace

using namespace KTools;
using namespace std;

typedef const VirtualDirectory &vd_t;
typedef const Compat::Path &p_t;
typedef const VirtualPath &vp_t;
typedef std::ios_base::openmode io_mode;

typedef KTools::VirtualDirectory::handler_pair_t handler_pair_t;

#define EXT(name, value)                                                       \
    static const KTools::lcstring name##EXT("." #value, sizeof("." #value) - 1)

EXT(ZIP, zip);
EXT(XML, xml);

static bool has_extension(lcstring s, lcstring ext) {
    return s.length() > ext.length() &&
           strncmp(ext, s + (s.length() - ext.length()), ext.length()) == 0;
}

static bool is_stdio(lcstring s) { return s.length() == 1 && s[0] == '-'; }

static VirtualDirectory::Type get_vd_type(lcstring path) {
    if (is_stdio(path)) {
        return VirtualDirectory::STANDARD_IO;
    }
#if defined(HAVE_LIBZIP)
    if (has_extension(path, ZIPEXT)) {
        return VirtualDirectory::ZIP;
    }
#endif
#if 0
	if(has_extension(path, XMLEXT)) {
		return VirtualDirectory::XML_ATLAS;
	}
#endif
    return VirtualDirectory::REGULAR;
}

///

template <typename T> static T unsupported_handler(vd_t, p_t, io_mode) {
    throw KToolsError(
        "Attempt to open virtual directory with unsupported handler.");
    return T();
}

///

static istream *regular_open_in(vd_t d, p_t p, io_mode mode) {
    istream *ret = new std::ifstream((d / p).c_str(), mode);
    check_stream_validity(*ret, d);
    return ret;
}

static ostream *regular_open_out(vd_t d, p_t p, io_mode mode) {
    ostream *ret = new std::ofstream((d / p).c_str(), mode);
    check_stream_validity(*ret, d);
    return ret;
}

static const handler_pair_t regular_handlers(regular_open_in, regular_open_out);

///

#if defined(HAVE_LIBZIP)
namespace {
class ZipArchive {
    struct zip *z;

    ZipArchive(const ZipArchive &);
    ZipArchive &operator=(const ZipArchive &);

  public:
    explicit ZipArchive(struct zip *_z) : z(_z) {}
    ~ZipArchive() {
        if (z != NULL) {
            zip_close(z);
        }
    }

    struct zip *get() const { return z; }
};

class ZipFile {
    struct zip_file *f;

    ZipFile(const ZipFile &);
    ZipFile &operator=(const ZipFile &);

  public:
    explicit ZipFile(struct zip_file *_f) : f(_f) {}
    ~ZipFile() {
        if (f != NULL) {
            zip_fclose(f);
        }
    }

    struct zip_file *get() const { return f; }
};

class CharBuffer {
    char *buf;

    CharBuffer(const CharBuffer &);
    CharBuffer &operator=(const CharBuffer &);

  public:
    explicit CharBuffer(char *_buf) : buf(_buf) {}
    ~CharBuffer() { delete[] buf; }

    char *get() const { return buf; }
    char *release() {
        char *tmp = buf;
        buf = NULL;
        return tmp;
    }
};
} // namespace

static istream *zip_open_in(vd_t d, p_t p, io_mode mode) {
    (void)mode;

    const Compat::Path &zippath = d;
    const Compat::UnixPath &entrypath = p;

    int errorcode;
    struct zip *z_raw = zip_open(zippath.c_str(), 0, &errorcode);
    if (z_raw == NULL) {
        char errbuf[1024];
        zip_error_to_str(errbuf, sizeof(errbuf) - 1, errorcode, errno);
        throw KToolsError("Failed to open " + zippath + ": " + errbuf);
    }
    ZipArchive z(z_raw);

    const zip_int64_t idx = zip_name_locate(z.get(), entrypath.c_str(), 0);
    if (idx < 0) {
        throw KToolsError("File " + entrypath + " does not exist in " +
                          zippath);
    }

    struct zip_stat entry_info;

    if (zip_stat_index(z.get(), idx, 0, &entry_info) != 0) {
        string zerr = zip_strerror(z.get());
        throw KToolsError("Failed to stat " + entrypath + " in " + zippath +
                          ": " + zerr);
    }

    struct zip_file *entry_raw =
        zip_fopen_index(z.get(), idx, ZIP_FL_UNCHANGED);
    if (entry_raw == NULL) {
        string zerr = zip_strerror(z.get());
        throw KToolsError("Failed to open " + entrypath + " in " + zippath +
                          ": " + zerr);
    }
    ZipFile entry(entry_raw);

    CharBuffer buffer(new char[entry_info.size]);

    const zip_int64_t read_cnt =
        zip_fread(entry.get(), buffer.get(), entry_info.size);

    if (read_cnt < 0) {
        string zerr = zip_file_strerror(entry.get());
        throw KToolsError("Failed to read contents of " + entrypath + " in " +
                          zippath + ": " + zerr);
    }

    return new bufferstream(buffer.release(), size_t(read_cnt));
}
#else
static const VirtualDirectory::in_handler_t zip_open_in = unsupported_handler;
#endif

static const handler_pair_t zip_handlers(zip_open_in, unsupported_handler);

///

static const handler_pair_t stdio_handlers(unsupported_handler,
                                           unsupported_handler);

///

static const handler_pair_t xml_atlas_handlers(unsupported_handler,
                                               unsupported_handler);

///

namespace KTools {
handler_pair_t VirtualDirectory::getHandlers() const {
    switch (type) {
    case ZIP:
        return zip_handlers;
        break;
    case STANDARD_IO:
        return stdio_handlers;
        break;
    case XML_ATLAS:
        return xml_atlas_handlers;
        break;
    default:
        return regular_handlers;
        break;
    }
    return regular_handlers;
}

VirtualDirectory VirtualPath::getVirtualDirectory(Compat::Path &subpath) const {
    lcstring path = *this;

    if (path.length() > 0) {
        size_t index = find(SEPARATOR, 0);
        const size_t index_end = path.length() - 1;

        for (; index < index_end; index = find(SEPARATOR, index + 1)) {
            lcstring dirpath(path, index);

            VirtualDirectory::Type t = get_vd_type(dirpath);

            if (t != VirtualDirectory::REGULAR &&
                t != VirtualDirectory::UNKNOWN) {
                if (find(SEPARATOR, index + 1) != string::npos) {
                    subpath = substr(index + 1);
                    return VirtualDirectory(dirpath.tostring(), t);
                }
            }
        }
    }

    subpath = basename();
    return VirtualDirectory(dirname(), VirtualDirectory::REGULAR);
}

#if defined(HAVE_LIBZIP)
bool VirtualPath::zipEntryExists(vd_t zippath,
                                 const Compat::UnixPath &entrypath) {
    struct zip *z_raw = zip_open(zippath.c_str(), 0, NULL);
    if (z_raw == NULL) {
        return false;
    }
    ZipArchive z(z_raw);

    zip_int64_t idx = zip_name_locate(z.get(), entrypath.c_str(), 0);

    return idx >= 0;
}
#endif
} // namespace KTools
