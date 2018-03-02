# SimMotorDocker
Docker file for creating the [SimMotor](https://github.com/mattclarke/SimMotor).

To build the image:
```
sudo docker build -t sim_motor .
```

To run:
```
sudo docker run --net=host -i sim_motor
```
