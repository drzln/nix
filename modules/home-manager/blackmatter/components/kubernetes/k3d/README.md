# k3d Home Manager Module

This module provides a convenient way to manage local Kubernetes clusters using **k3d** through Nix and Home Manager. It supports enabling/disabling k3d, configuring a default cluster, and adding multiple additional clusters. Each cluster is managed as a systemd user service for easy lifecycle management.

## Features

- **Enable or Disable k3d**: Quickly toggle k3d support on your system.
- **Default Cluster**: Automatically sets up a default k3d cluster accessible at a specified address.
- **Additional Clusters**: Configure multiple additional clusters with custom ports and API addresses.
- **Systemd Integration**: Clusters are managed as systemd user services, ensuring they start, stop, and restart predictably.

---

## Options

### `blackmatter.kubernetes.k3d.enable`

- **Type**: `boolean`
- **Default**: `false`
- **Description**: Enable or disable k3d integration. When set to `true`, k3d is installed, and clusters are managed as systemd services.

### `blackmatter.kubernetes.k3d.address`

- **Type**: `string`
- **Default**: `"127.0.0.1"`
- **Description**: The API address for the default cluster. Typically, this is `127.0.0.1:6443` for local usage.

### `blackmatter.kubernetes.k3d.additionalClusters`

- **Type**: `list of attributes`
- **Default**: `[]`
- **Description**: A list of additional clusters to configure. Each cluster must define:
  - `name`: The cluster's name (e.g., `dev-cluster`).
  - `apiPort`: The API address for the cluster (e.g., `127.0.0.2:6443`).
  - `ports`: A list of custom port mappings for the cluster (e.g., `["8080:80@loadbalancer"]`).

---

## Usage

### Basic Configuration (Default Cluster)

```nix
{
  blackmatter.kubernetes.k3d = {
    enable = true;
    address = "127.0.0.1:6443";
  };
}

```

### Advanced configuration

```nix
{
  blackmatter.kubernetes.k3d = {
    enable = true;
    address = "127.0.0.1:6443";
    additionalClusters = [
      {
        name = "dev-cluster";
        apiPort = "127.0.0.2:6443";
        ports = [
          "8080:80@loadbalancer"
          "8443:443@loadbalancer"
        ];
      }
      {
        name = "test-cluster";
        apiPort = "127.0.0.3:6443";
        ports = [
          "9090:80@loadbalancer"
        ];
      }
    ];
  };
}
```
