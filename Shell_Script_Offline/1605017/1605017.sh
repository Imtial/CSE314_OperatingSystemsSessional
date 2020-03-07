root=`pwd`
if [ $# -eq 0 ]; then
    echo "No argument is given"
    echo "SYNOPSIS: ./script.sh [working directory] input_file"
    echo "EXAMPLE: ./script.sh work_dir input.txt"
    exit 1
elif [ $# -eq 1 ]; then
    file=$1
    if [[ "$1" == *"/"* ]]; then
        root=`echo "$1" | sed 's/\(.*\)\/.*/\1/'`
    fi
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

IFS=$'\n'
file_list=( $(grep -wril "$str" "$root") )

for f in "${file_list[@]}"
do
    matched_list=( $(grep -win "$str" "$f") )
    
    case "$portion" in
        "begin")
            i=`echo "${matched_list[0]}" | cut -d ':' -f 1`
            if [ "$i" -le "$n" ]; then
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
            fi
            ;;
        "end")
            tloc=`wc -l < "$f"`
            i=`echo "${matched_list[-1]}" | cut -d ':' -f 1`
            if [ "$i" -ge "$(( $tloc-$n ))" ]; then
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
            fi
            ;;
    esac

    for line in "${matched_list[@]}"
    do
        lnum=`echo "$line" | cut -d ':' -f 1`
        text=`echo "$line" | cut -d ':' -f 2`
        # FOR ALL SEARCHED TEXT
        # echo "$f","$lnum","$text" >> "$f_csv"

        # FOR SEARCHED TEXT IN THE REQUIRED PORTION
        case "$portion" in
        "begin")
            if [ "$lnum" -le "$n" ]; then
                echo "$f","$lnum","$text" >> "$f_csv"        
            fi
            ;;
        "end")
            tloc=`wc -l < "$f"`
            if [ "$lnum" -ge "$(( $tloc-$n ))" ]; then
                echo "$f","$lnum","$text" >> "$f_csv"
            fi
            ;;
    esac
    done
done

echo "Number of files which matched the criteria: $count"