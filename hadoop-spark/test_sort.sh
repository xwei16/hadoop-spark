function test_terasorting() {
    # call your program here
    docker compose -f cs511p1-compose.yaml cp resources/cap-3.csv main:/cap.csv > /dev/null 2>&1
    docker compose -f cs511p1-compose.yaml exec main bash -x -c '\
        hdfs dfs -mkdir -p /test; \
        hdfs dfs -put -f /cap.csv /test/cap.csv; \
        hdfs dfs -cat /test/cap.csv' > /dev/null 2>&1
    
    docker compose -f cs511p1-compose.yaml cp resources/cap.scala main:/cap.scala > /dev/null 2>&1
    docker compose -f cs511p1-compose.yaml exec main bash -x -c '\
        cat /cap.scala | spark-shell --master spark://main:7077' > /dev/null 2>&1
    
    docker compose -f cs511p1-compose.yaml exec main bash -c '\
        hdfs dfs -cat /test/output_caps/part-00000 > /cap_out.csv' > /dev/null 2>&1
    docker compose -f cs511p1-compose.yaml cp main:/cap_out.csv cap_out.csv > /dev/null 2>&1
    cat cap_out.csv
    # make sure your program outputs only the result on screen
    # echo "please rewrite this function";
}

echo -n "Testing Tera Sorting ..."
test_terasorting > out/test_terasorting.out 2>&1
if diff --strip-trailing-cr resources/example-terasorting-3.truth out/test_terasorting.out; then
    echo -e " ${GREEN}PASS${NC}"
    (( total_score+=20 ));
else
    echo -e " ${RED}FAIL${NC}"
fi