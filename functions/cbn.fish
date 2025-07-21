#!/usr/bin/env fish

# CBN - column by name: print out the value of a column by the value of the first
# line in that column (i.e., the column's heading).
function cbn
  set -l name $argv[1]
  if test -z "$name"
    echo "Usage: cbn COLUMN_NAME" >&2
    echo 'cbn - column by name; like "awk {print $N}" without knowing the position N' >&2
    return 1
  end

  # Create temporary file to store input
  set -l tmpfile (mktemp)
  cat > $tmpfile

  # Find column number
  set -l col_num (head -n 1 $tmpfile | awk -v name=$name '
    {
      for(i=1; i<=NF; i++) {
        if($i==name) {
          print i
          exit
        }
      }
    }
  ')

  if test -z "$col_num"
    echo "Error: Column \"$name\" not found" >&2
    rm $tmpfile
    return 1
  end

  # Print the specified column for all rows
  awk -v cn=$col_num '{print $cn}' $tmpfile

  # Clean up
  rm $tmpfile
end
