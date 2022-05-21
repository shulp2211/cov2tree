name: Custom
on:
  repository_dispatch:
  workflow_dispatch:

# A workflow run is made up of one or more jobs that can run sequentially or in parallel
jobs:
  # This workflow contains a single job called "build"
  create:
    # The type of runner that the job will run on
    runs-on: macos-latest
    defaults:
      run:
        shell: bash -l {0}
    # Steps represent a sequence of tasks that will be executed as part of the job
    steps:
      - uses: conda-incubator/setup-miniconda@v2
        with:
         activate-environment: usher
         python-version: 3.9
         channels: conda-forge,bioconda
      - run: |
          conda info
          conda list
          conda install usher
      - name: matUtils
        run: matUtils version
      - name: which
        run: which python3
      - name: which
        run: which python
      - name: Set up S3cmd cli tool
        uses: s3-actions/s3cmd@v1.2.0
        with:
          provider: aws # default is linode
          region: 'eu-central-1'
      - uses: actions/checkout@v2
        with:
          token: ${{ secrets.GITHUB_TOKEN }}
      - name: Process
        run: source custom.sh
        env: 
          MYKEY: ${{ secrets.DO_KEY }}
  redeploykube:
    uses: theosanderson/cov2tree/.github/workflows/kube_restart.yaml@main
    secrets: inherit
    needs: create
