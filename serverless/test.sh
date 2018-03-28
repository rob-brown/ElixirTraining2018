#! /bin/sh

echo "Fetching dependencies"

mix deps.get

echo "Generating function JSON"

PORT=4000 mix run -e "\
fun = fn %{\"x\" => x, \"y\" => y} -> x + y end
bin = :erlang.term_to_binary fun
ascii = Base.encode16 bin
json = Poison.encode! %{\"fun\" => ascii}
File.write \"add_fun.json\", json
"

echo "Starting server"

PORT=4000 iex -S mix &

PID=$!

sleep 5

echo "Uploading function"

function upload {
  curl -X "POST" "http://localhost:4000/add-function" \
       -H 'Content-Type: application/json' \
       --data-binary @add_fun.json \
       2>/dev/null
}

ID=$(upload)

echo $ID

echo "Calling function"

function call {
  curl -X "POST" "http://localhost:4000/call/$1" \
       -H 'Content-Type: application/json; charset=utf-8' \
       -d $'{
         "x": 42,
         "y": 43
       }' \
       2>/dev/null
}

RESULT=$(call $ID)

echo "Got result $RESULT"

echo "Cleaning up"

rm "add_fun.json"

kill -KILL $PID
