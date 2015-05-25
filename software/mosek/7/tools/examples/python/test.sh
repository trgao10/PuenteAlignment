printf "* Testing Python\n"

PYTHON=python
if [ "$#" -ge "1" ]; then
   PYTHON=$1
fi

for f in  "lo1" "lo2" "qo1" "cqo1" "sdo1" "qcqo1" "sensitivity" "milo1"; do
    printf "\nExample: $f.py\n"
    $PYTHON $f.py 
done

for f in  "concurrent1" "concurrent2"; do
    printf "\nExample: $f.py\n"
    $PYTHON $f.py ../data/25fv47.mps
done

printf '** done testing Python\n\n'
