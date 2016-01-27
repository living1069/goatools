"""GOEA and report generation w/bonferroni multiple test corrections from statsmodels.

        python test_goea_rpt_bonferroni.py
        python test_goea_rpt_bonferroni.py [LOG FILENAME]
"""

__copyright__ = "Copyright (C) 2016, DV Klopfenstein, H Tang. All rights reserved."
__author__ = "DV Klopfenstein"

import sys

sys.path.insert(0, '..') # Use local version of goatools during test
from goatools.obo_parser import GODag
from goatools.associations import read_associations

from PyBiocode.enrichanal.enrichanal_GO import GOEA

def test_bonferroni(fout_log=None):
    """Do Gene Ontology Enrichment Analysis w/Bonferroni multipletest. Print results 3 ways."""
    # ---------------------------------------------------------------------
    # Run Gene Ontology Analysis (GOEA)
    #
    # 1. Initialize
    log = sys.stdout if fout_log is None else open(fout_log, 'w')
    obo_dag = GODag("go-basic.obo")
    assoc = read_associations("../data/association", no_top=True)
    popul_ids = [line.rstrip() for line in open("../data/population")]
    study_ids = [line.rstrip() for line in open("../data/study")]
    # 2. Run enrichment analysis
    goea = GOEA(obo_dag, assoc, log)
    goea.set_population(popul_ids)
    goea.set_params(alpha=0.05, method='bonferroni')
    results_nt = goea.find_enrichment(study_ids)

    # ---------------------------------------------------------------------
    # Print results 3 ways: to screen, to tsv (tab-separated file), to xlsx (Excel spreadsheet)
    fout_tsv = "goea_bonferroni.tsv"
    fout_xls = "goea_bonferroni.xlsx"
    
    # print these in tsv and xlsx
    print_names = ['NS', 'study_cnt', 'pval_uncor', 'bonferroni_star', 'bonferroni', 'level', 'depth', 'GO', 'name'] 
    field_names = print_names + ['bonferroni_sig'] # collect this. Used in prt_if
    # Optional user customizable sort: 
    #     Sort by: 1st) BP, MF, CC; 2nd) corrected pval, with smallest last.
    sort_by = lambda nt: [nt.NS, -1*nt.pval_uncor]
    # 1. Print results to screen using format in prtfmt. For example:
    #
    #      BP 22 3.073e-03 L06 D07 GO:0006468 protein phosphorylation
    #      BP  9 1.023e-02 L07 D08 GO:0006511 ubiquitin-dependent protein catabolic process
    #      BP  2 1.023e-02 L05 D09 GO:0019877 diaminopimelate biosynthetic process
    #      BP  2 1.223e-02 L04 D08 GO:0006301 postreplication repair
    #      BP  2 1.223e-02 L05 D09 GO:0030418 nicotianamine biosynthetic process
    #      BP  2 1.492e-02 L04 D06 GO:0006909 phagocytosis
    #      BP  2 1.492e-02 L03 D03 GO:0051322 anaphase
    #      ...
    # Print format field names are the same names as in the "field_names" variable.
    prtfmt = " ".join(["{NS} {study_cnt:2} {pval_uncor:5.3e}",
             "{bonferroni_star:1} {bonferroni:5.3e} L{level:02} D{depth:02} {GO} {name}\n"])
    prt_if = lambda nt: nt.bonferroni_sig # T/F: Keep the GOEA GO Term result only if the result is significant.
    goea.prt_txt(log, results_nt, field_names, prtfmt, sort_by=sort_by, prt_if=prt_if)

    # 2. Write results to tsv file
    # Optional user defined formatting for specific fields
    fld2fmt = {'bonferroni':'{:8.2e}', 'pval_uncor':'{:8.2e}'} 
    # Sort by: 1st) BP, MF, CC; 2nd) By GO depth, deepest GO first.
    sort_by = lambda nt: [nt.NS, -1*nt.depth] 
    goea.wr_tsv(fout_tsv, results_nt, field_names, 
        prt_if=prt_if, sort_by=sort_by, fld2fmt=fld2fmt, print_names=print_names)

    # 3. Write results to xlsx file
    # Use these headers instead of the print_names for the xlsx header
    hdrs = ['NS', 'Cnt', '*', 'bonferroni', 'L', 'D', 'Term', 'Ontology Term Name']
    # TBD Check that header and size of fields printed match
    goea.wr_xlsx(fout_xls, results_nt, field_names, 
        # optional key-word args (ie, kwargs, kws)
        prt_if=prt_if, sort_by=sort_by, hdrs=hdrs, fld2fmt=fld2fmt, print_names=print_names) 
    if fout_log is not None:
        log.close()
        sys.stdout.write("  WROTE: {}\n".format(fout_log))

if __name__ == '__main__':
    test_bonferroni(GOEA.get_fout_log())

# Copyright (C) 2016, DV Klopfenstein, H Tang. All rights reserved.
