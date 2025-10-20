val rdd = sc.textFile("hdfs://main:9000/test/cap.csv")

// key-val : year, serial -> 
val caps = rdd.map{ line => 
    val parts = line.split(",")
    val year = parts(0).toInt
    val serial = parts(1).trim
    (year, serial)
}

//filter 2025
val filtered_caps = caps.filter{ case(year, _)  => year <= 2025}

//sort
val sorted_caps = filtered_caps.sortBy{ case(year, serial) => (-year, serial) }

//collect
val final_caps = sorted_caps.map{ case(year, serial) => s"${year},${serial}"}
//save
final_caps.coalesce(1).saveAsTextFile("hdfs://main:9000/test/output_caps")
