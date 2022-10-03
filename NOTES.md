# Steps

I created a Github to house the authors' original code, using the original files (that is an option when downloading from Dataverse manually).

I separately cloned the Dataverse repository to WholeTale, using the one-button import.

This creates slightly different versions of the download.

I then cloned the Github onto WholeTale:

```
git clone https://github.com/larsvilhuber/reproduction-105683-sp3-dwxhg9.git
```

and re-aligned the two versions (file endings differ).

When I first pushed to Github, I got this prompt:

```
*** Please tell me who you are.

Run

  git config --global user.email "you@example.com"
  git config --global user.name "Your Name"

to set your account's default identity.
Omit --global to set the identity only in this repository.
```

To make this "stick", I used the non-global version to do so.

Because I had previously run this on WholeTale (not the right order...), I already had some files there. I did get the following:

```
[master 643c1ba] Re-aligning code
 17 files changed, 156 insertions(+), 627 deletions(-)
 delete mode 100644 dataverse-dwxhg9/BDOtransitory_replication/code/ado/plus/_/_eststo.ado
 delete mode 100644 dataverse-dwxhg9/BDOtransitory_replication/code/ado/plus/_/_eststo.hlp
 rewrite dataverse-dwxhg9/BDOtransitory_replication/output/Figure_01c.pdf (68%)
 rewrite dataverse-dwxhg9/BDOtransitory_replication/output/Figure_01d.pdf (65%)
 ```

 which you can see [here](https://github.com/larsvilhuber/reproduction-105683-sp3-dwxhg9/commit/643c1bae77a1274cb73c6fc2b63b9f40d94f2c6e). The first `delete` lines can be ignored, but the two `rewrite`  lines indicate that there may be differences in the two Figure 1 panels (but not in the other panels!) to keep an eye out for. However, these rewrites in PDFs may also be technical (date stamps), and not be meaningful. 
 
 When pushing, I needed to provide a "password". 
 
 > This should not be the Github password, but rather a "[personal access token](https://github.com/settings/tokens)"!

 ## Scripts

 I created a project-specific `run.sh` (within the author's directory structure) and a Wholetale-specific `run-all.sh` (at the root of the WT workspace):

 - `work/workspace/reproduction-105683-sp3-dwxhg9/dataverse-dwxhg9/BDOtransitory_replication/run.sh`

```
 #!/bin/bash

cd code
stata-mp -b do 0_BDOtransitory_MAIN.do
```

- `work/workspace/run-all.sh`

```
#!/bin/bash

# run the project specific run.sh
cd reproduction-105683-sp3-dwxhg9/dataverse-dwxhg9/BDOtransitory_replication
chmod a+rx run.sh
./run.sh 
```

