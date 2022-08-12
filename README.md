# MetaMOPE
Live version is freely available at https://metamope.cmdm.tw

## Description
### Motivation
Liquid chromatography coupled with mass spectrometry (LC-MS) is widely used in metabolomics studies,
while HILIC LC-MS is particularly suited for polar metabolites. Determining an optimized mobile phase and
developing a proper liquid chromatography method tend to be laborious, time-consuming, and empirical.

### Results
We developed a containerized web tool providing a workflow to quickly determine the optimized mobile
phase by batch evaluating chromatography peaks for metabolomics LC-MS studies. A mass chromatographic quality
value, an asymmetric factor, and the local maximum intensity of the extracted ion chromatogram were calculated to
determine the number of peaks and peak retention time. The optimal mobile phase can be quickly determined by
selecting the mobile phase that produces the largest number of resolved peaks. Moreover, the workflow enables one to
automatically process the repeats by evaluating chromatography peaks and determining the retention time of large
numbers of standards. This workflow was successfully applied to construct a reference library of 571 metabolites for
the HILIC LC-MS platform.

## Prerequisite
1. Install Docker
2. Install Git

## How to start
1. Run `git clone git@github.com:CMDM-Lab/MetaHILIC.git` to get all source code
2. Rename .env.example to .env, and edit .env for environment variables.
3. Run `docker-compose up --build`
4. Access http://localhost:13002 through the browser
