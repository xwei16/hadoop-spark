function test_pagerank() {
    docker compose -f cs511p1-compose.yaml cp resources/network.csv main:/network.csv > /dev/null 2>&1
    docker compose -f cs511p1-compose.yaml exec main bash -c '\
        hdfs dfs -mkdir -p /network; \
        hdfs dfs -put -f /network.csv /network/network.csv; \
        hdfs dfs -rm -r -f /network/output_pagerank' > /dev/null 2>&1

    docker compose -f cs511p1-compose.yaml cp resources/pagerank.scala main:/pagerank.scala > /dev/null 2>&1
    docker compose -f cs511p1-compose.yaml exec main bash -c '\
        cat /pagerank.scala | spark-shell --master spark://main:7077' > /dev/null 2>&1


    docker compose -f cs511p1-compose.yaml exec main bash -c '\
        hdfs dfs -cat /network/output_pagerank/part-00000 > /pagerank_out.csv' > /dev/null 2>&1
    docker compose -f cs511p1-compose.yaml cp main:/pagerank_out.csv pagerank_out.csv > /dev/null 2>&1
    cat pagerank_out.csv
}


echo -n "Testing PageRank (extra credit) ..."
test_pagerank > out/test_pagerank.out 2>&1
if diff --strip-trailing-cr resources/example-pagerank.truth out/test_pagerank.out; then
    echo -e " ${GREEN}PASS${NC}"
    (( total_score+=20 ));
else
    echo -e " ${RED}FAIL${NC}"
fi
