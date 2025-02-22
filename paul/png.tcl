#!/usr/bin/env tclsh
## 
# Code from the Wiki
# https://wiki.tcl-lang.org/page/Write+PNG+File+%28without+using+Tk%29
##############################################################################

package provide PNG 1.0
package require Tcl 8.6
namespace eval PNG {
    namespace ensemble create -subcommands [list write size]
    # Write a PNG file to disk.
    #
    # filename - Output file name.
    # palette  - Ordered list of RGB color values in hex notation. List
    #            length must be <= 256.
    # image    - Image data as a list of scanlines each of which is a list
    #            of palette index values for the pixels in the scanline.
    proc write { filename palette image } {
        set fid [open ${filename} w]
        fconfigure ${fid} -translation binary
        set width [llength [lindex ${image} 0]]
        set height [llength ${image}]
        puts -nonewline ${fid} [binary format c8 {137 80 78 71 13 10 26 10}]
        set data {}
        append data [binary format I ${width}]
        append data [binary format I ${height}]
        # bit depth 8, color type 3 (each pixel is a palette index)
        append data [binary format c5 {8 3 0 0 0}]
        Chunk ${fid} "IHDR" ${data}
        set data {}
        set unique-colors [lsort -dictionary -unique ${image}]
        set palette-size 0
        foreach color ${palette} {
            append data [binary format H6 ${color}]
            incr palette-size
        }
        if { ${palette-size} < 256 } {
            set fill [binary format H6 000000]
            append data [string repeat ${fill} [expr {256-${palette-size}}]]
        }
        Chunk ${fid} "PLTE" ${data}
        set data {}
        foreach scanline ${image} {
            # add filter type to the beginning of each scanline
            append data [binary format c 0]     ;# type 0 (no filter)
            foreach pixel ${scanline} {
                append data [binary format c ${pixel}]
            }
        }
        set cdata [binary format H* 78da]
        append cdata [zlib deflate ${data}]
        append cdata [binary format I [zlib adler32 ${data}]]
                
        Chunk ${fid} "IDAT" ${cdata}
        Chunk ${fid} "IEND"     
        close ${fid}
        return ""
    }
    # ===== Private Procedures =====
    proc Chunk { fid type {data ""} } {
        set length [binary format I [string length ${data}]]
        puts -nonewline ${fid} ${length}
        puts -nonewline ${fid} [encoding convertto ascii ${type}]
        if { ${data} ne "" } {
            puts -nonewline ${fid} ${data}  
        }
        set crcdata "${type}${data}"
        set crc [zlib crc32 ${crcdata}]
        puts -nonewline ${fid} [binary format I ${crc}]
    }
    proc size {filename} {
        if {![file exists $filename]} {
            error "Error: File $filename does not exists!"
        }
        if {[file size $filename] < 33} {
            error "File $filename not large enough to contain PNG header"
        }
        set f [open $filename r]
        fconfigure $f -translation binary
        
        # Read PNG file signature
        binary scan [read $f 8] c8 sig
        foreach b1 $sig b2 {-119 80 78 71 13 10 26 10} {
            if {$b1 != $b2} {
                close $f
                error "$filename is not a PNG file"
            }
        }
        
        # Read IHDR chunk signature
        binary scan [read $f 8] c8 sig
        foreach b1 $sig b2 {0 0 0 13 73 72 68 82} {
            if {$b1 != $b2} {
                close $f
                error "$filename is missing a leading IHDR chunk"
            }
        }
        
        # Read off the size of the image
        binary scan [read $f 8] II width height
        # Ignore the rest of the data, including the chunk CRC!
        #binary scan [read $f 5] ccccc depth type compression filter interlace
        #binary scan [read $f 4] I chunkCRC
        
        close $f
        return [list $width $height]
    }
}

if 0 {
set palette {FFFFFF 000000 FF0000 00FF00 0000FF FFFF00 FF00FF}
set image {
{1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1}
{1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1}
{1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1}
{1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1}
{1 0 0 1 1 1 1 1 1 1 1 0 0 0 3 3 3 3 0 0 0 2 2 0 0 0 0 0 0 0 0 1}
{1 0 0 1 1 1 1 1 1 1 1 0 0 3 3 3 3 3 3 0 0 2 2 0 0 0 0 0 0 0 0 1}
{1 0 0 0 0 0 1 1 0 0 0 0 0 3 3 0 0 3 3 0 0 2 2 0 0 0 0 0 0 0 0 1}
{1 0 0 0 0 0 1 1 0 0 0 0 0 3 3 0 0 0 0 0 0 2 2 0 0 0 0 0 0 0 0 1}
{1 0 0 0 0 0 1 1 0 0 0 0 0 3 3 0 0 0 0 0 0 2 2 0 0 0 0 0 0 0 0 1}
{1 0 0 0 0 0 1 1 0 0 0 0 0 3 3 0 0 0 0 0 0 2 2 0 0 0 0 0 0 0 0 1}
{1 0 0 0 0 0 1 1 0 0 0 0 0 3 3 0 0 0 0 0 0 2 2 0 0 0 0 0 0 0 0 1}
{1 0 0 0 0 0 1 1 0 0 0 0 0 3 3 0 0 3 3 0 0 2 2 0 0 0 0 0 0 0 0 1}
{1 0 0 0 0 0 1 1 0 0 0 0 0 3 3 3 3 3 3 0 0 2 2 2 2 2 2 2 0 0 0 1}
{1 0 0 0 0 0 1 1 0 0 0 0 0 0 3 3 3 3 0 0 0 2 2 2 2 2 2 2 0 0 0 1}
{1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1}
{1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1}
{1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1}
{1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1}
{1 0 4 4 4 4 4 4 0 0 0 1 1 0 0 0 0 1 1 0 0 6 6 6 6 6 6 6 6 0 0 1}
{1 0 4 4 4 4 4 4 4 0 0 1 1 0 0 0 0 1 1 0 0 6 6 6 6 6 6 6 6 0 0 1}
{1 0 4 4 0 0 0 4 4 0 0 1 1 1 0 0 0 1 1 0 0 6 6 0 0 0 0 0 0 0 0 1}
{1 0 4 4 0 0 0 4 4 0 0 1 1 1 1 0 0 1 1 0 0 6 6 0 0 0 0 0 0 0 0 1}
{1 0 4 4 0 0 0 4 4 0 0 1 1 0 1 1 0 1 1 0 0 6 6 0 0 6 6 6 6 0 0 1}
{1 0 4 4 4 4 4 4 4 0 0 1 1 0 0 1 1 1 1 0 0 6 6 0 0 6 6 6 6 0 0 1}
{1 0 4 4 4 4 4 4 0 0 0 1 1 0 0 0 1 1 1 0 0 6 6 0 0 0 0 6 6 0 0 1}
{1 0 4 4 0 0 0 0 0 0 0 1 1 0 0 0 0 1 1 0 0 6 6 0 0 0 0 6 6 0 0 1}
{1 0 4 4 0 0 0 0 0 0 0 1 1 0 0 0 0 1 1 0 0 6 6 6 6 6 6 6 6 0 0 1}
{1 0 4 4 0 0 0 0 0 0 0 1 1 0 0 0 0 1 1 0 0 6 6 6 6 6 6 6 6 0 0 1}
{1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1}
{1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1}
{1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1}
{1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1}
}
PNG write test.png ${palette} ${image}
puts [PNG size test.png]
}
