#include <Rcpp.h>
#include <algorithm>
#include <vector>
#include <unordered_map>
using namespace Rcpp;

//' Fast peak detection using sliding window
//'
//' @param positions Integer vector of genomic positions (must be sorted)
//' @param tags Numeric vector of tag counts at each position
//' @param peakDistance Integer, maximum distance for peak calling
//' @return Integer vector of peak indices (0 = not a peak, index = is a peak)
//' @export
// [[Rcpp::export]]
IntegerVector findPeaksCpp(IntegerVector positions,
                           NumericVector tags,
                           int peakDistance) {

  int n = positions.size();
  IntegerVector peakID(n, 0); // Initialize all to 0

  if(n == 0) return peakID;

  // Validate inputs
  if(positions.size() != tags.size()) {
    stop("positions and tags must have same length");
  }
  if(peakDistance <= 0) {
    stop("peakDistance must be positive");
  }

  // For each position, find if it's a peak in its window
  for(int i = 0; i < n; i++) {
    int current_pos = positions[i];
    double current_tag = tags[i];

    // Find window boundaries using binary search (much faster!)
    // Since positions are sorted, we can use efficient search
    int left = i;
    int right = i;

    // Expand left boundary
    while(left > 0 && positions[left-1] >= current_pos - peakDistance) {
      left--;
    }

    // Expand right boundary
    while(right < n-1 && positions[right+1] <= current_pos + peakDistance) {
      right++;
    }

    // Check if current position has maximum tag in window
    bool is_peak = true;
    int max_idx = i;
    double max_tag = current_tag;

    for(int j = left; j <= right; j++) {
      if(tags[j] > max_tag || (tags[j] == max_tag && j < max_idx)) {
        max_tag = tags[j];
        max_idx = j;
        is_peak = false;
      }
    }

    // If current position is the peak, mark it
    if(is_peak || i == max_idx) {
      peakID[i] = i + 1; // R uses 1-based indexing
    }
  }

  return peakID;
}


//' Fast local filtering based on peak threshold
//'
//' @param positions Integer vector of positions
//' @param tags Numeric vector of tag counts
//' @param peakIndices Integer vector of peak indices (from findPeaksCpp)
//' @param peakDistance Integer, distance for local filtering
//' @param localThreshold Numeric, threshold ratio (e.g., 0.02)
//' @param strand Character, "+" or "-" for strand direction
//' @return Logical vector indicating which positions to keep (TRUE = keep)
//' @export
// [[Rcpp::export]]
LogicalVector localFilterCpp(IntegerVector positions,
                              NumericVector tags,
                              IntegerVector peakIndices,
                              int peakDistance,
                              double localThreshold,
                              std::string strand) {

  int n = positions.size();
  LogicalVector keep(n, true); // Keep all by default

  if(n == 0) return keep;

  // Get indices of peaks only (where peakIndices > 0)
  std::vector<int> peak_positions;
  for(int i = 0; i < n; i++) {
    if(peakIndices[i] > 0) {
      peak_positions.push_back(i);
    }
  }

  // For each peak, filter nearby positions
  for(size_t p = 0; p < peak_positions.size(); p++) {
    int peak_idx = peak_positions[p];
    int peak_pos = positions[peak_idx];
    double peak_tag = tags[peak_idx];
    double threshold = peak_tag * localThreshold;

    // Define filtering region based on strand
    int region_start, region_end;
    if(strand == "+") {
      region_start = peak_pos;
      region_end = peak_pos + peakDistance;
    } else {
      region_start = peak_pos - peakDistance;
      region_end = peak_pos;
    }

    // Mark positions to remove
    for(int i = 0; i < n; i++) {
      if(positions[i] >= region_start && positions[i] <= region_end) {
        if(tags[i] < threshold && i != peak_idx) {
          keep[i] = false;
        }
      }
    }
  }

  return keep;
}


//' Fast quantile calculation using cumulative sum
//'
//' @param positions Integer vector of positions (sorted)
//' @param tags Numeric vector of tag counts
//' @param quantile Numeric, quantile to calculate (e.g., 0.1)
//' @param from_end Logical, calculate from end (for upper quantile)
//' @return Integer, position at the quantile
//' @export
// [[Rcpp::export]]
int calculateQuantilePositionCpp(IntegerVector positions,
                                  NumericVector tags,
                                  double quantile,
                                  bool from_end = false) {

  int n = positions.size();
  if(n == 0) return NA_INTEGER;

  // Calculate total sum
  double total = 0.0;
  for(int i = 0; i < n; i++) {
    total += tags[i];
  }

  double threshold = total * quantile;
  double cumsum = 0.0;

  if(from_end) {
    // Calculate from end (for q_0.9)
    for(int i = n-1; i >= 0; i--) {
      cumsum += tags[i];
      if(cumsum > threshold) {
        return positions[i];
      }
    }
    return positions[0];
  } else {
    // Calculate from start (for q_0.1)
    for(int i = 0; i < n; i++) {
      cumsum += tags[i];
      if(cumsum > threshold) {
        return positions[i];
      }
    }
    return positions[n-1];
  }
}


//' Calculate cluster quantiles efficiently
//'
//' @param positions Integer vector of positions
//' @param tags Numeric vector of tags
//' @param cluster_starts Integer vector of cluster start indices
//' @param cluster_ends Integer vector of cluster end indices
//' @return DataFrame with q_0.1, q_0.9, and interquantile_width
//' @export
// [[Rcpp::export]]
DataFrame calculateClusterQuantilesCpp(IntegerVector positions,
                                        NumericVector tags,
                                        IntegerVector cluster_starts,
                                        IntegerVector cluster_ends) {

  int n_clusters = cluster_starts.size();
  IntegerVector q01(n_clusters);
  IntegerVector q09(n_clusters);
  IntegerVector iq_width(n_clusters);

  for(int c = 0; c < n_clusters; c++) {
    int start_idx = cluster_starts[c] - 1; // Convert to 0-based
    int end_idx = cluster_ends[c] - 1;

    if(start_idx < 0 || end_idx >= positions.size() || start_idx > end_idx) {
      q01[c] = NA_INTEGER;
      q09[c] = NA_INTEGER;
      iq_width[c] = NA_INTEGER;
      continue;
    }

    // Extract cluster positions and tags
    int cluster_size = end_idx - start_idx + 1;
    IntegerVector cluster_pos(cluster_size);
    NumericVector cluster_tags(cluster_size);

    for(int i = 0; i < cluster_size; i++) {
      cluster_pos[i] = positions[start_idx + i];
      cluster_tags[i] = tags[start_idx + i];
    }

    // Calculate quantiles
    q01[c] = calculateQuantilePositionCpp(cluster_pos, cluster_tags, 0.1, false);
    q09[c] = calculateQuantilePositionCpp(cluster_pos, cluster_tags, 0.1, true);
    iq_width[c] = q09[c] - q01[c] + 1;
  }

  return DataFrame::create(
    Named("q_0.1") = q01,
    Named("q_0.9") = q09,
    Named("interquantile_width") = iq_width
  );
}


//' Test function to compare R and C++ implementations
//'
//' @param n Integer, number of test positions
//' @return List with test data
//' @export
// [[Rcpp::export]]
List generateTestData(int n = 10000) {
  // Generate sorted positions
  IntegerVector positions(n);
  for(int i = 0; i < n; i++) {
    positions[i] = i * 10; // Positions every 10bp
  }

  // Generate random tags
  NumericVector tags(n);
  for(int i = 0; i < n; i++) {
    tags[i] = R::runif(0, 100); // Random between 0 and 100
  }

  return List::create(
    Named("positions") = positions,
    Named("tags") = tags
  );
}
