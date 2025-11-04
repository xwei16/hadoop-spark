import faiss
import h5py
import numpy as np
import os
import requests
def download_file(url, dest_path, chunk_size=8192):
    r = requests.get(url, stream=True)
    r.raise_for_status()
    with open(dest_path, "wb") as f:
        for chunk in r.iter_content(chunk_size=chunk_size):
            if chunk:
                f.write(chunk)

def evaluate_hnsw():

    # start your code here
    # download data, build index, run query

    # write the indices of the 10 approximate nearest neighbours in output.txt, separated by new line in the same directory
    
    # -----------------------------
    # 1. Download dataset (HDF5 version) from ANN-Benchmarks
    # -----------------------------
    data_url = ("http://ann-benchmarks.com/sift-128-euclidean.hdf5")
    local_hdf5 = "./sift-128-euclidean.hdf5"

    if not os.path.exists(local_hdf5):
        print("Downloading HDF5 dataset for SIFT...")
        download_file(data_url, local_hdf5)
        print("Download completed.")

    # -----------------------------
    # 2. Load dataset
    # -----------------------------
    print("Loading dataset from HDF5 file …")
    with h5py.File(local_hdf5, "r") as f:
        xb = f["train"][:]      # train embeddings
        xq = f["test"][:]       # query embeddings
        # (If there’s a “neighbors” or “gt” dataset, we could load it too but we only need queries/DB.)
    print(f"Database vectors shape: {xb.shape}")
    print(f"Query vectors shape: {xq.shape}")

    # -----------------------------
    # 3. Create HNSW index (no PQ)
    # -----------------------------
    d = xb.shape[1]
    M = 16
    efConstruction = 200
    efSearch = 200

    print("Building HNSW index …")
    index = faiss.IndexHNSWFlat(d, M)
    index.hnsw.efConstruction = efConstruction
    index.hnsw.efSearch = efSearch

    index.add(xb)
    print(f"Index built with {index.ntotal} vectors.")

    # -----------------------------
    # 4. Perform a query
    # -----------------------------
    query_vec = xq[0:1]  # first query vector
    k = 10
    D, I = index.search(query_vec, k) # D: distances, I: indices

    print("Top-10 neighbor indices:", I[0])

    # -----------------------------
    # 5. Write results
    # -----------------------------
    output_path = "./output.txt"
    with open(output_path, "w") as f_out:
        for idx in I[0]:
            f_out.write(str(idx) + "\n")

    print(f"Results written to {output_path}")

if __name__ == "__main__":
    evaluate_hnsw()
