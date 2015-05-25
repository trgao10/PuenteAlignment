printf "* Testing Java\n"

MOSEKJAR=$1

for f in  "lo1" "lo2" "cqo1" "sdo1" "qo1" "qcqo1" "sensitivity" "milo1" "concurrent1"; do
    javac -classpath $MOSEKJAR -d . $f.java
done

for f in  "lo1" "lo2" "cqo1" "sdo1" "qo1" "qcqo1" "sensitivity" "milo1"; do
    printf "\n** Example: $f\n"
    java -classpath $MOSEKJAR:. com.mosek.example.$f 
done

for f in  "concurrent1"; do
    printf "\n** Example: $f\n"
    java -classpath $MOSEKJAR:. com.mosek.example.$f ../data/25fv47.mps
done

printf '* done testing Java\n\n'
