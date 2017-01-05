# MC-PortScan
A tool to discover not properly protected bungee backend servers written in Ruby

### Preview:
![Preview](https://dl.sapphyrus.xyz/v8me7sq6gzakl53r.png)

### Usage: 
```sh
$ ruby MC-PortScan.rb [HOSTNAME] [MIN PORT] [MAX PORT] [MAX THREADS] [DELAY]
```
ex.
```sh
$ ruby MC-PortScan.rb kadcon.de 25000 65535 500 0.01
```