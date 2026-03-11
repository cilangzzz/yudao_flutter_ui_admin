// Minimal ATL replacement for flutter_secure_storage_windows
// Provides CA2W and CW2A string conversion classes without requiring ATL installation

#ifndef ATLSTR_H
#define ATLSTR_H

#include <string>
#include <windows.h>

// CA2W: Convert ANSI (char) to Wide (wchar_t)
class CA2W {
public:
    CA2W(const char* str) : m_str(nullptr) {
        if (str) {
            int len = MultiByteToWideChar(CP_ACP, 0, str, -1, nullptr, 0);
            if (len > 0) {
                m_str = new wchar_t[len];
                MultiByteToWideChar(CP_ACP, 0, str, -1, m_str, len);
            }
        }
    }

    ~CA2W() {
        delete[] m_str;
    }

    operator const wchar_t*() const {
        return m_str;
    }

    wchar_t* m_psz;

private:
    wchar_t* m_str;
    CA2W(const CA2W&) = delete;
    CA2W& operator=(const CA2W&) = delete;
};

// CW2A: Convert Wide (wchar_t) to ANSI (char)
class CW2A {
public:
    CW2A(const wchar_t* str) : m_str(nullptr) {
        if (str) {
            int len = WideCharToMultiByte(CP_ACP, 0, str, -1, nullptr, 0, nullptr, nullptr);
            if (len > 0) {
                m_str = new char[len];
                WideCharToMultiByte(CP_ACP, 0, str, -1, m_str, len, nullptr, nullptr);
            }
        }
    }

    ~CW2A() {
        delete[] m_str;
    }

    operator const char*() const {
        return m_str;
    }

private:
    char* m_str;
    CW2A(const CW2A&) = delete;
    CW2A& operator=(const CW2A&) = delete;
};

#endif // ATLSTR_H