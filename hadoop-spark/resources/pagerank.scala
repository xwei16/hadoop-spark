val file = sc.textFile("hdfs://main:9000/network/network.csv")
val edges = file.map{ line => 
  val parts = line.split(",")
  val src = parts(0).toInt
  val dst = parts(1).toInt
  (src, dst)
}.cache()

// Collect nodes and build mappings
val nodes = edges.flatMap{ case (src, dst) => List(src, dst) }.distinct().collect().sorted
val nodeToIndex = nodes.zipWithIndex.toMap
val indexToNode = nodeToIndex.map(_.swap)
val n = nodes.length

// Build adjacency list and transition matrix
val links = edges.groupByKey().collectAsMap()
val M = Array.tabulate(n, n) { (i, j) =>
  val src = indexToNode(j)
  val outgoing = links.getOrElse(src, Iterable.empty[Int])
  if (outgoing.nonEmpty) {
    if (outgoing.exists(_ == indexToNode(i))) 1.0 / outgoing.size else 0.0
  } else 1.0 / n
}

val d = 0.85
val tol = 1e-4
val maxIter = 1000

// Power iteration - functional approach with recursion
def powerIteration(pr: Array[Double], iter: Int): (Array[Double], Int) = {
  if (iter >= maxIter) (pr, iter)
  else {
    val newPr = Array.tabulate(n) { i =>
      (1 - d) / n + d * (0 until n).map(j => M(i)(j) * pr(j)).sum
    }
    val diff = pr.zip(newPr).map { case (a, b) => math.abs(a - b) }.sum
    if (diff < tol) (newPr, iter + 1)
    else powerIteration(newPr, iter + 1)
  }
}

val (pr, iterations) = powerIteration(Array.fill(n)(1.0 / n), 0)
println(s"Converged after $iterations iterations")

// Prepare and save results
val result = sc.parallelize(
  nodes.zip(pr)
    .sortBy { case (_, r) => -r }
    .map { case (node, r) => f"$node,$r%.3f" }
)

result.coalesce(1).saveAsTextFile("hdfs://main:9000/network/output_pagerank")
