cat $1 | head -n50 | grep -w wire
echo ""
cat $1 | head -n50 | grep -w wire | sed -E 's/\[[0-9:]*\]//g' | sed 's/\r//g' | sed 's/,//g' | awk '{print "."$3"("$3"),"}'
# ^ removes widths (ex. [15:0]), CRs (\r), commas, and prints a port-list format
