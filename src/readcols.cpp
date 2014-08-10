/*
 * read columns of a 3-col file
 *
 *  Created on: Jul 26, 2014
 *      Author: kaiyin
 */

#include "readcols.h"

// [[Rcpp::export]]
std::vector<std::vector<std::string> > readcols(std::string fn,
		std::vector<unsigned int> colsel, size_t nFirstSkipLines,
		size_t nSkipUnit) {

	if (colsel.empty()) {
		throw std::string("You didn't select any column!");
	}


	size_t nc_file = ncols(fn);
	Rcpp::Rcout << "File has " << nc_file << " columns \n";
	size_t nr_file = countlines(fn);
	Rcpp::Rcout << "File has " << nr_file << " rows \n";

	Rcpp::Rcout << "You want to skip the first " <<  nFirstSkipLines << " lines \n";
	Rcpp::Rcout << "Of the rest you want to select one line out of every " << nSkipUnit << " lines \n";
	size_t nr = (size_t) ((nr_file - nFirstSkipLines) / nSkipUnit);
	Rcpp::Rcout << "You selected " << nr << " rows \n";
	size_t nc = colsel.size();
	Rcpp::Rcout << "You selected " << nc << " columns \n";


	{
		size_t remainder = (size_t) ((nr_file - nFirstSkipLines) % nSkipUnit);
		if (remainder != 0) {
			std::cerr
					<< "Number of lines to read is not a multiple of nSkipUnit! \n";
			nr++;
		}
	}

	unsigned int colsel_max = *std::max_element(colsel.begin(), colsel.end());

	if (colsel_max > nc_file) {
		throw std::string("Some col number(s) are out of range!");
	}

	// c++ is 0-based, adjust for it
	for (unsigned int i = 0; i < colsel.size(); i++) {
		colsel[i]--;
	}

	// initialize a 2d vector (matrix) with fixed size
	std::vector<std::vector<std::string> > res(nc,
			std::vector<std::string>(nr));
	std::ifstream infile(fn);
	std::string tmpline;

	// skip lines in the beginning
	for (int lineIter = 0; lineIter < nFirstSkipLines; lineIter++) {
		getline(infile, tmpline);
	}

	size_t rowIter = 0;
	for (size_t lineIter = 0; lineIter < nr_file; lineIter++) {
		std::string line;
		getline(infile, line);
		if (lineIter % nSkipUnit == 0) {
			istringstream lineStream(line);
			size_t colIter = 0;
			for (size_t wordIter = 0; wordIter <= colsel_max; wordIter++) {
				std::string tmpword;
				lineStream >> tmpword;
				if (std::find(colsel.begin(), colsel.end(), wordIter)
						!= colsel.end()) {
					res[colIter][rowIter] = tmpword;
					colIter++;
				}
			}
			rowIter++;
		}
	}

	return res;
}

