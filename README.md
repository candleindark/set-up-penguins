This repo provides the BASH scripts to set up the 
[Penguins empirical data annotation demo editor](https://penguins.edu.datalad.org/ui/) 
locally.

## Prerequisites
The scripts assume you have the following software installed:
- [micromamba](https://mamba.readthedocs.io/en/latest/user_guide/micromamba.html) for environment management
- [datalad](https://www.datalad.org/) for downloading data to populate the demo editor backend

## Setup Instructions
To set up the demo editor (with backend support) locally, follow these steps:

1. Run `./setup-stack.sh`. (This will create the needed directories with contents to start the editor (frontend)
   and its backend support. Following the instructions printed by the script to start both frontend and 
   backend services in separate terminal sessions. Notes: The script also prints out
   token information for viewing and editing the data in the demo editor.)
2. After starting both the frontend and backend services, run `./populate-backend.sh` to
   populate the backend with empirical data from the Penguins dataset.

## Notes:
1. The following micromamba environment will be created as result of running the above scripts:
   - penguins-backend        
   - penguins-frontend       
   - penguins-populate       
2. `config.sh` contains configuration variables used by the setup scripts.
3. The frontend and backend of [Penguins empirical data annotation demo editor](https://penguins.edu.datalad.org/ui/) are
   instances of [schacl-vue](https://hub.psychoinformatics.de/datalink/shacl-vue.git) 
   and [dump-things-server](https://hub.psychoinformatics.de/inm7/dump-things-server).
   for details on the configuration of these components, please refer to their respective
    documentation.
4. Data used to populate the demo editor originate from [Penguins Dataset](https://hub.datalad.org/edu/penguins),
   which provides [scripts](https://hub.datalad.org/edu/penguins/src/branch/main/code) to carry out the population.
