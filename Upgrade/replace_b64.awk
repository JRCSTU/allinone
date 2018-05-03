/_BASE64_ARCHIVE_HERE__/ { 
    while ((getline line < "_archive.tar.bz2.b64") > 0)
        print line
    next
}
{print}
