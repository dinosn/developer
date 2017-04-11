
## principles

- everyone can use their developer tools on their native laptop/pc eg. atom/sourcetree
- DRY: do not repeat yourself
- reproducable environments for all developers
    - all libraries are exactly the same for each developer
- reproducable build environments for all developers
    - from this env you can build for our g8os platform, we want this to be reproducable
- ability to work together by using zerotier networks (can login into development machines only from your peer's)
    - zerotier networks allow you to work together independant where you are (behind nat, ...)
- ssh enabled
    - the development machine always runs on 2222 and there is only 1
    - we use ssh this allows us to use our cuisine tools in jumpscale & work together with others
    - this also allows git to be seamless used (login ssh -A ..., this allows keys to be reused) in the docker
- if there is a need to use more than 1 machine or develop against other (p)machines
    - DO NOT USE MULTIPLE DOCKERS AT SAME TIME on your development machine
    - use remote VM's, physical machines, ... anywhere on the internet
    - use the remote development tools which are part of jumpscale, this again gives us reproducability
