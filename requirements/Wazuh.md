# Server requirements

[Link](https://documentation.wazuh.com/current/installation-guide/wazuh-server/index.html#requirements)

## OS

64-bit Linux:
- Amazon Linux 2
- **CentOS 7**, 8
- Red Hat Enterprise Linux 7, 8, 9
- Ubuntu 16.04, 18.04, **20.04, 22.04**

## Hardware recommendations

### RAM and CPU

Minimum: 

| RAM (GB) | CPU (Cores) |
| --- | --- |
| 2 | 2 | 

Recommended:

| RAM (GB) | CPU (Cores) |
| --- | --- |
| 4 | 8 |

### Disk space

Depends on generated APS (Alterts Per Second).
The table below is an estimate for the APS and storage requirement for *one* device.

| Monitored endpoints | APS | Storage in Wazuh indexer (GB/90 days) |
| --- | --- | --- |
| Servers | 0.25 | 0.1 |
| Workstations | 0.1 | 0.04 |
| Network devices | 0.5 | 0.2 |

## Scaling

Monitor the following files:

- `var/ossec/var/run/wazuh-analysisd.state`: the variable `events_dropped` indicates whether events are being dropped due to lack of resources.
- `/var/ossec/var/run/wazuh-remoted.state`: the variable `discarded_count` indicates if messages from the agents were discarded.

If both variables are zero, the environment is working properly.

# Indexer requirements

[Link](https://documentation.wazuh.com/current/installation-guide/wazuh-indexer/index.html#requirements)

## OS

64-bit Linux:
- Amazon Linux 2
- **CentOS 7**, 8
- Red Hat Enterprise Linux 7, 8, 9
- Ubuntu 16.04, 18.04, **20.04, 22.04**

## Hardware recommendations

### RAM and CPU

Minimum: 

| RAM (GB) | CPU (Cores) |
| --- | --- |
| 4 | 2 | 

Recommended:

| RAM (GB) | CPU (Cores) |
| --- | --- |
| 16 | 8 |

### Disk space

Depends on generated APS (Alterts Per Second).
The table below is an estimate for the APS and storage requirement for *one* device.

| Monitored endpoints | APS | Storage in Wazuh indexer (GB/90 days) |
| --- | --- | --- |
| Servers | 0.25 | 3.7 |
| Workstations | 0.1 | 1.5 |
| Network devices | 0.5 | 7.4 |

# Dashboard requirements

[Link](https://documentation.wazuh.com/current/installation-guide/wazuh-dashboard/index.html#requirements)

## OS

64-bit Linux:
- Amazon Linux 2
- **CentOS 7**, 8
- Red Hat Enterprise Linux 7, 8, 9
- Ubuntu 16.04, 18.04, **20.04, 22.04**

## Hardware recommendations

### RAM and CPU

Minimum: 

| RAM (GB) | CPU (Cores) |
| --- | --- |
| 4 | 2 | 

Recommended:

| RAM (GB) | CPU (Cores) |
| --- | --- |
| 8 | 4 |

## Browser compatability

- Chrome 95 (or later)
- Fireforx 93 (or later)
- Safari 13.7 (or later)
