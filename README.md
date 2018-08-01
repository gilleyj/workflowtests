# DEIS - CIRCLE CI integration

***
***this is a work in progress***
***

## Setting up GitHub

Add a circle.yml file

Set branch security to only build PRs (unless you WANT every branch built)

## Setting up CircleCI

Required environment variables (per project)

* `DEIS_HOME` - The deis URL minus `deis.` for example if your deis cluster is `http://deis.somewhere.co/` this should be `somewhare.co`
* `DEIS_USER` - your deis user that will be doing deployments to deis
* `DEIS_PASS` - password for above

You will also need to generate and add an SSH key to the circle ci project and add the .pub key to the deis account you're using here.

as well as add the ssh_key to the circle.yaml:

```
      - add_ssh_keys:
          fingerprints:
            - "so:me:fi:ng:er:pr:in:t."
```

**Assumptions**

* The DEIS root domain url is `deis.DEIS_HOME`
* The DEIS builder domain url is `deis-builder.DEIS_HOME`

Optional environment variables for Slack Notifications:

* `SLACK_HOOK` - A full url that is a webhook to your slack account
* `SLACK_CHANNEL` - the channel to send your notifications to e.g. `#mission-control`

### circle.yaml setup

#### Call the setup script:

```
      - run:
          name: Setup DEIS command...
          command: |
            curl -sSL https://gist.githubusercontent.com/gilleyj/265e271c15b29258e33d3e1c2b5a99a0/raw/deis_setup.sh | bash
```

`deis_setup.sh` script does the following:

* tests for required variables
* adds the host ssh fingerprint to ~/.ssh/known_hosts
* download and install the `deis` cli
* login to your deis cluster
* test to make sure the user has access to proceed on the cluster
* creates a new pod if it does not already exist


#### Call the deploy script:

```
      - run:
          name: Deploy to our pod...
          command: |
            curl -sSL https://gist.githubusercontent.com/gilleyj/81c365a9f2afc94ba183f0e5d834ce83/raw/deis_deploy.sh | bash
```

`deis_setup.sh` script does the following:

* tests for the deis cli
* tests for required variables
* bundles and sends the project ENV vars to the deis cluster
* bundles and sends the project to deis to be built
* if setup will notify slack
