root=`pwd`
if [ $# -eq 0 ]; then
    echo "No argument is given"
    echo "SYNOPSIS: ./script.sh [working directory] input_file"
    echo "EXAMPLE: ./script.sh work_dir input.txt"
    exit 1
elif [ $# -eq 1 ]; then
    file=$1
    while [ ! -f $file ]
    do
        echo "File not found!"
        echo "Enter a valid input file name(Ctrl-c to exit the program): "
        read file
    done
elif [ $# -eq 2 ]; then
    root=$1
    file=$2
elif [ $# -gt 2 ]; then
    echo "Too many arguments"
    exit 1
fi

portion=`head -n 1 $file` 
n=`head -n 2 $file | tail -1`
str=`tail -1 $file | sed -e 's/\(.*\)/\L\1/'`

count=0

out_dir="$root/../output_dir"
f_csv="$root/../output.csv"

rm -rf "$out_dir" "$f_csv"

mkdir -p "$out_dir"
touch "$f_csv"
echo "File Path,Line Number,Line Containing The Searched Text" >> "$f_csv"

operation() {
    f=$1
    p=$2
    nline=$3
    s=$4
    tline=`wc -l < "$f"`

    case "$p" in
        "begin") 
            for((i=1; i<"$nline"; i++)); do
                line=`head -n "$i" "$f" | tail -n 1 | sed -e 's/\(.*\)/\L\1/'`
                if [[ "$line" == *"$s"* ]]; then
                    echo "$f","$i","$line" >> "$f_csv"
                    ((count=count+1))
                    ext=`echo "$f" | sed -e 's/.*\.//g'`
                    if [[ "$ext" = "$f" ]]; then
                        basename=`echo "$f" | sed -e 's/\//./g'`
                        # echo "cp "$f" ""$out_dir"/"$basename""$i"""
                        cp "$f" ""$out_dir"/""$basename""$i"""
                    else
                        basename=`echo "$f" | sed -e "s/\.$ext//g" -e 's/\//./g'`
                        # echo "cp "$f" ""$out_dir"/""$basename""$i"."$ext""""
                        cp "$f" ""$out_dir"/""$basename""$i"."$ext"""
                    fi
                    break
                fi
            done
            ;;
        "end")
            for((i=1; i<"$nline"; i++)); do
                line=`tail -n "$i" "$f" | head -n 1 | sed -e 's/\(.*\)/\L\1/'`
                if [[ "$line" == *"$s"* ]]; then
                    echo "$f","$(( $tline-$i+1 ))","$line" >> "$f_csv"
                    ((count=count+1))
                    ext=`echo "$f" | sed -e 's/.*\.//g'`
                    if [[ "$ext" = "$f" ]]; then
                        basename=`echo "$f" | sed -e 's/\//./g'`
                        # echo "cp "$f" ""$out_dir"/"$basename""$(( $tline-$i+1 ))"""
                        cp "$f" ""$out_dir"/""$basename""$(( $tline-$i+1 ))"""
                    else
                        basename=`echo "$f" | sed -e "s/\.$ext//g" -e 's/\//./g'`
                        # echo "cp "$f" ""$out_dir"/"$basename""$(( $tline-$i+1 ))"."$ext"""
                        cp "$f" ""$out_dir"/""$basename""$(( $tline-$i+1 ))"."$ext"""
                    fi
                    break
                fi
            done
            ;;
    esac    
}

while IFS= read -r -d '' -u 9
do
    if [ -f "$REPLY" ]; then
        type=`file -bi "$REPLY" | sed -e 's/.*charset=//g'`
        if [ "$type" = "us-ascii" -o "$type" = "utf-8" ]; then
            operation "$REPLY" "$portion" "$n" "$str"
        fi
    fi
done 9< <( find "$root" -type f -print0 )

echo "Number of files which matched the criteria: $count"