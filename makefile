# configuration for Gene Ontology files
GO_OBO_FILE=go-basic.obo
GOSLIM_OBO_FILE=goslim_generic.obo

GO_OBO_DOWNLOAD=http://geneontology.org/ontology/go-basic.obo
GOSLIM_OBO_DOWNLOAD=http://www.geneontology.org/ontology/subsets/goslim_generic.obo
GOEA_FILES = data/study data/population data/association

# Example GO: translation factor activity RNA binding
GO = GO:0008135


# -------------------------------------------------------------------------------
# ---- Sphinx-Generated Documentation -------------------------------------------
# -------------------------------------------------------------------------------

# GENERATE A TEMPORARY LOCAL WORKING COPY of Sphinx docs when developing documentation.
#
# User your browser to view the temporary local html files located at:
#   <LOCAL_GIT_ROOT>/sphinx/_build/html/index.html
#
# Html files generated using "mkdocs" should not be committed or pushed.
# Use the "gh-pages" make target to generate html docs which will be saved in the "goatools" "GitHub Pages".
# "GitHub Pages" are public webpages hosted and published through the goatools repository.
.PHONY: mkdocs rmdocs gh-pages
mkdocs:
	make -C sphinx/ apidoc html

# REMOVE THE TEMPORARY LOCAL WORKING COPY of Sphinx docs after a session of developing documentation.
rmdocs:
	make clean_docgen

# GENERATE SPHINX HTML DOCS DISPLAYED ON-LINE.
#
# Make target, "gh-pages" does the following:
#   1. Switches from the "master" branch to the "gh-pages" branch
#   2. While in the "gh-pages" branch, checks out from the "master" branch:
#      a. Sphinx control files
#      b. GOATOOLS source code, which contains docstrings
#         The docstrings are used to create Sphinx html documentation
#   3. Creates html documentation using Sphinx in the "gh-pages" branch.
#   4. Commits and pushes html docs from "gh-pages" branch.
#   5. Switches back to the master branch
gh-pages:
	@echo "TBD: GOATOOLS GitHub Pages coming Soon"


# -------------------------------------------------------------------------------
# ---- Run Scripts --------------------------------------------------------------
# -------------------------------------------------------------------------------
goea: $(GO_OBO_FILE)
	python scripts/find_enrichment.py --pval=0.05 --indent $(GOEA_FILES)

goea_scipy_pval: $(GO_OBO_FILE)
	python scripts/find_enrichment.py --pval=0.05 --indent $(GOEA_FILES) --pvalcalc fisher_scipy_stats

goea_basic: $(GO_OBO_FILE)
	python scripts/find_enrichment.py $(GOEA_FILES)

goea_xlsx: $(GO_OBO_FILE)
	python scripts/find_enrichment.py --pval=0.05 --indent $(GOEA_FILES) --outfile=goea.xlsx

goea_xlsx_bonferroni: $(GO_OBO_FILE)
	python scripts/find_enrichment.py --pval=0.05 --indent $(GOEA_FILES) --method=bonferroni --outfile=goea_bonferroni.xlsx

goea_tsv: $(GO_OBO_FILE)
	python scripts/find_enrichment.py --pval=0.05 --indent $(GOEA_FILES) --outfile=goea.tsv

goea_files: $(GO_OBO_FILE)
	python scripts/find_enrichment.py --pval=0.05 --indent $(GOEA_FILES) --outfile=goea.tsv,goea.xlsx

plot_go_pygraphviz: $(GO_OBO_FILE)
	python scripts/plot_go_term.py --term=$(GO)

plot_go_pydot: $(GO_OBO_FILE)
	python scripts/plot_go_term.py --term=$(GO) --engine=pydot

map_slim: $(GO_OBO_FILE) $(GOSLIM_OBO_FILE)
	python scripts/map_to_slim.py --association_file=data/association --slim_out=direct $(GO_OBO_FILE) $(GOSLIM_OBO_FILE)


goea_all: goea goea_basic goea_xlsx goea_xlsx_bonferroni goea_tsv goea_files


# if the gene ontology files don't exist, download them
$(GO_OBO_FILE):
	@echo "downloading GO file: $(GO_OBO_FILE)"
	wget -O $(GO_OBO_FILE) $(GO_OBO_DOWNLOAD)

$(GOSLIM_OBO_FILE):
	@echo "downloading GOslim file: $(GOSLIM_OBO_FILE)"
	wget -O $(GOSLIM_OBO_FILE) $(GOSLIM_OBO_DOWNLOAD)

clean:
	rm -f goea*.xlsx goea.tsv GO_lineage.png
	cd tests; make --no-print-directory clean

# Removes local files in master branch generated using Sphinx
clean_docgen:
	rm -rf ./_apidoc/
	rm -rf ./_modules/
	rm -rf ./_sources/
	rm -rf ./_static/
	rm -f genindex.html
	rm -f index.html
	rm -f objects.inv
	rm -f py-modindex.html
	rm -f search.html
	rm -f searchindex.js
	rm -rf sphinx/_apidoc/
	rm -rf sphinx/_build/
	rm -f fetch_associations.html
	rm -f find_enrichment.html
	rm -f goatools.html
	rm -f map_to_slim.html
	rm -f modules.html
	rm -f plot_go_term.html
	rm -f write_hierarchy.html

clobber:
	@make --no-print-directory clean
	rm -f $(GO_OBO_FILE) $(GOSLIM_OBO_FILE)

test:
	nosetests tests/test_goea_statsmodels.py tests/test_get_paths.py