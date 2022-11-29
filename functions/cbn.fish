#!/usr/bin/env fish

# CBN - column by name: print out the value of a column by the value of the first
# line in that column (i.e., the column's heading).
function cbn
  set -l name $argv[1]
  if [ -z $name ]
    echo "Usage: cbn COLUMN_NAME" >&2
    echo 'cbn - column by name; like "awk {print $N}" without knowing the position N' >&2
    return
  end
  gawk -v name=$name '
    NR==1 {
      for(i=1; i<=NF; i++) {
        if($i==name) {
          cn=i
          print $cn
          break
        }
      }
    }
    NR>1 {
      print $cn
    }
  '
end
