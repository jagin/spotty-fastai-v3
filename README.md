# Fast.ai course v3 on AWS Spot Instances

This repository allows you to run Jupyter Notebooks from [fast.ai](https://www.fast.ai/)
course [Practical Deep Learning for Coders, v3](https://course.fast.ai/) in a cheapest
way on [AWS Spot Instances](https://aws.amazon.com/ec2/spot/).

AWS Spot Instnces allows you to cut the cost of your GPU instance by about 75%. 
They are spare unused Amazon EC2 instances (for the course we are interested in
[P2](https://aws.amazon.com/ec2/instance-types/p2/) and [P3](https://aws.amazon.com/ec2/instance-types/p3/)
instances) that you can bid for. Once your bid exceeds the current spot price the instance is launched.
As the spot prices fluctuates in real time based on demand-and-supply the instance can go away anytime
the spot price becomes greater than your bid price. The downside is, it will remove your instance entirely
and you will lose your work.

The solution for managing all necessary AWS resources including AMIs, volumes and snapshots in the way 
that your work will be preserved is [Spotty](https://github.com/apls777/spotty) which was greatly described in
the article [How to train Deep Learning models on AWS Spot Instances using Spotty?](https://towardsdatascience.com/how-to-train-deep-learning-models-on-aws-spot-instances-using-spotty-8d9e0543d365)
by Oleg Polosin, the author of Spotty.

Please read this article and Spotty documentation to know how it works.

## Requirements

1. [Python 3] (https://www.python.org/downloads/)
2. AWS account (see [Sign Up](https://portal.aws.amazon.com/billing/signup#/start) page if you don't have one)
3. Installed AWS CLI for your account (see [Installing the AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html)).

## Setup

1. Clone this repository

```bash
$ git clone https://github.com/jagin/spotty-fastai-v3
$ cd spotty-fastai-v3
```

2. Install Spotty

```bash
$ pip install -U spotty
```

3. Find the cheapest region for your spot p2.xlarge instance

```bash
$ spotty spot-prices -i p2.xlarge
```
You should get something like:
```
Getting spot instance prices for "p2.xlarge"...

Price  Zone
0.2700 us-east-2c
0.2700 us-east-2b
0.2700 us-west-2a
0.2700 us-west-2b
0.2751 us-west-2c
0.2916 eu-west-1a
0.2924 eu-west-1c
0.2947 eu-west-1b
0.2949 us-east-1d
0.2960 us-east-1e
0.3015 us-east-1a
0.3037 us-east-1b
0.3140 us-east-2a
0.3648 us-east-1f
0.3690 us-east-1c
0.3978 eu-central-1b
```
We can clearly see that us-east-2 and us-west-2 region is the cheapest by now.  
You can also select other instance type if you want but p2.xlarge should suffice for the course.

4. [Configuring the AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html) with selected region

I would strongly suggest to create separate [named profile](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-profiles.html)
*faceid* for your account with the selected region. Don't forget to set `AWS_PROFILE` environment variable for your named profile.

5. Update `spotty.yaml`

Edit `spotty.yaml` file and set your `region` and `instanceType` in the `instance` section.

6. Create an AMI with NVIDIA Docker

Run the following command from the project directory (where the `spotty.yaml` file is located):
```bash
$ spotty create-ami
```
It will take some time (several minutes) to create an AMI that can be used for all your projects within the AWS region.

7. Start an instance

```bash
$ spotty start
```
It will run a Spot Instance, create or mount your volumes, restore snapshots if any, synchronize the project with the running instance and start the Docker container with the environment.
Notice an IP address of your spot instnce for further reference.

8. Setup the course notebooks

```bash
$ spotty run setup
```
Running the first time it will clone [fastai/course-v3](https://github.com/fastai/course-v3) repository. Running the `spotty run setup` command again will pull the changes for the repo.

9. Run the Jupyter Notebook

```bash
$ spotty run jupyter
```
Notice the `?token=your_jupyter_notebook_token` string.
Open a browser and type the following url http://your_spot_instnce_ip:8888/?token=your_jupyter_notebook_token

To query your GPU device state open separate terminal (be sure that your *faceid* AWS profile is selected) and run:
```bash
$ spotty run nvsmi
```

To connect to the running container via SSH, use the following command:
```bash
$ spotty ssh
```
It runs a tmux session, so you can always detach this session using **Crtl + b**, then **d** combination of keys. To be attached to that session later, just use the `spotty ssh` command again.

10. Stop the instance

After finishing your work **don't forget to stop the instance** running:
```bash
$ spotty stop
```
The volume with your data will be unmunted from the instance. When you will be starting an instance next time, it will mount the volume automatically.
You can also instruct Spotty to create a snapshot of your volume (it is cheaper than persisting the volume but will take longer to recreate the instance with a new volume).
See [Spotty Configuration](https://github.com/apls777/spotty/wiki/Configuration-File) for `instance.volumes.deletionPolicy`
When you’re stopping the instance, Spotty automatically creates snapshots of the volumes. When you will be starting an instance next time, it will restore the snapshots automatically.

## Credits

I would like to thank Oleg Polosin for his great work and support for [Spotty](https://github.com/apls777/spotty).

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
