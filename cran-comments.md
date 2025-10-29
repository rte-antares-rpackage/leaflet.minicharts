## Test environments
* local OS X install, R 3.6.1
* ubuntu 14.04 (on travis-ci), R 3.6.1
* win-builder (devel and release)

## R CMD check results

0 errors | 0 warnings | 1 note

* Re-Fixing CRAN URL not in canonical form in README, Sorry for that. Thank you!

## Version: 0.6.3
* update person, new maintener Tatiana Vargas
* Fix/comment tests =>  
  - '`with_mock()` was deprecated in testthat 3.3.0. 
  Please use `with_mocked_bindings()` instead'
  
## Test environments
* R version 4.1.2 (2021-11-01)
* Platform: x86_64-pc-linux-gnu (64-bit)
* Running under: Ubuntu 22.04.4 LTS

## R CMD check results (only local warnings/notes)
❯ checking data for ASCII and uncompressed saves ... OK
   WARNING
  ‘qpdf’ is needed for checks on size reduction of PDFs

❯ checking for future file timestamps ... NOTE
  unable to verify current time

0 errors ✔ | 1 warning ✖ | 1 note ✖


# Re-Fixing OLD Travis URL in README (deleted), 
Sorry for that (didn't see that with local check `rcmdcheck::rcmdcheck(args = "--as-cran")`. 
Thank you!

 
