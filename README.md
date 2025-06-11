## Why Frappista SNE?

Developing for ERPNext can often involve complex setup processes that consume valuable time and resources. As developers and contributors, we at Vyogo Technology recognized this challenge and set out to create a solution that would streamline the development workflow. Today, I'm excited to share our contribution to the ERPNext ecosystem: the Single Node Environment (SNE) for development purposes.

## What is SNE?

The Single Node Environment (SNE) is a specialized Docker container solution designed to eliminate the lengthy setup process typically required for ERPNext development. SNE provides a pre-installed, bootable container that comes with a ready-to-use site and all necessary apps already configured.

## Key Features

### 1. Pre-installed and Ready to Run
Unlike other solutions that require additional configuration after pulling the image, SNE containers are completely pre-installed. When the container starts, the bench automatically launches with dev.localhost, allowing you to begin development immediately.

### 2. Custom App creation

# 🛠️ Frappe Custom App Creator Utility

This utility simplifies the process of creating and managing Frappe custom apps using a Docker-based setup with the `vyogo/erpnext:sne-version-15` image.

## 🚀 Features

- Create a new Frappe app inside the container and mount it locally
- Automatically update your `compose.yml` file to include volume mounts
- Interactive app creation using `bench new-app`
- Optional mode to just update the compose file without creating the app

---

## 🐧 Linux/macOS (Recommended)

Use the `create_custom_frappe_app.sh` script:

### ✅ Usage

```bash
# Create a new Frappe app and optionally update compose.yml
./create_custom_frappe_app.sh my_app

# Only update compose.yml to mount an already created app
./create_custom_frappe_app.sh my_app --compose-update-only


### 3. Easy Custom App Mounting
SNE facilitates easy mounting of custom apps, making it ideal for developers working on multiple apps simultaneously.

### 4. Gitpod Integration
We've designed SNE to work seamlessly with Gitpod, enabling cloud-based development environments that are consistent across your team.

## How SNE Differs from Other Solutions

The primary difference between SNE and other available solutions is our focus on immediate productivity. While most containers require additional installation steps, configuration, or site creation after initialization, our containers are:

1. **Pre-installed**: All necessary components are already set up
2. **Pre-configured**: The site is created and ready to use
3. **Instantly available**: As soon as the container starts, you can access dev.localhost

This approach dramatically reduces the time from container initialization to actual development work.

## Technical Implementation

SNE leverages Source-to-Image (s2i) based builds to create these pre-configured containers. This approach allows us to:

1. Execute the entire installation process during the image build
2. Commit the fully configured state to the container image
3. Ensure consistency across all deployments of the image

## Getting Started with SNE

### Quick Start

#### Using Docker

Pull the appropriate image based on your needs:

```bash
# For ERPNext v15
docker pull vyogo/erpnext:sne-version-15

# For the development branch
docker pull vyogo/erpnext:sne-develop

# For the latest stable release
docker pull vyogo/erpnext:sne-latest
```

Run the container:

```bash
docker run -p 8000:8000 -p 9000:9000 vyogo/erpnext:sne-version-15
```

Once started, access your development environment at http://dev.localhost:8000

#### Using Docker Compose

For a more streamlined setup, especially when mounting custom apps for development, you can use Docker Compose. Copy the `compose.yml` file to your app root and replace `{custom_appname}` with the name of your custom app. This configuration mounts your local app directory into the container's apps directory, enabling real-time development.

Start your development environment with:

```bash
docker-compose up
```
This approach is particularly useful for teams working on custom apps as it ensures everyone has the same development environment while allowing local changes to be immediately reflected in the running container.

## GitPod Based Remote Environments

### Transform Your ERPNext Development Experience

**Tired of endless setup times and environment inconsistencies?** Say goodbye to the days of "it works on my machine" excuses and hello to instant, cloud-powered development with our ERPNext Single Node Environment (SNE) for GitPod!

### 🚀 Zero to Coding in 60 Seconds

Our pre-built SNE images revolutionize remote development by eliminating the painful configuration process that traditionally plagues ERPNext development. With SNE + GitPod integration, you can:

- **Start coding immediately** with a fully-configured ERPNext environment that boots instantly
- **Access your development environment from anywhere** on any device with an internet connection
- **Skip hours of setup time** that would otherwise be wasted on installation and configuration

### 💪 Why GitPod + SNE is a Game-Changer

#### Instant Gratification
No more waiting for bench to install, dependencies to resolve, or sites to create. Click the GitPod button and your entire environment—complete with a running ERPNext instance at dev.localhost—is ready before your coffee gets cold.

#### Collaboration Without Friction
Onboard new team members in minutes instead of days. Share your exact environment with a simple URL.

#### Consistent Development Environment
Eliminate the "works on my development machine but breaks in production" nightmare. Every team member works in identical environments.

### 🛠️ Setup Your Repository

Add this to your `.gitpod.yml` file:

```yaml
image: docker.io/vyogo/erpnext:sne-latest

ports:
  - port: 8000
    onOpen: open-preview
  - port: 9000
    onOpen: ignore

tasks:
  - init: echo "Environment ready!"
    command: /usr/libexec/s2i/run

### Customizing Your Build

To include custom apps in your SNE build:

1. Fork our repository: https://github.com/vyogotech/frappista
2. Modify the app.json file to include your custom apps
3. Build your customized image using the provided scripts

## Real-world Benefits

Using SNE in our development workflow has yielded significant improvements:

1. **Time savings**: Developers can start working on code within minutes instead of hours
2. **Consistent environments**: Everyone works with identical setups, eliminating "works on my machine" issues
3. **Improved onboarding**: New team members can get up and running quickly
4. **Resource efficiency**: Less time spent on setup means more time for actual development

## Future Roadmap

At Vyogo, we're committed to continuing innovation on this project. Some features we're planning include:

1. Additional version support
2. Enhanced customization options
3. Improved performance optimizations
4. Better integration with CI/CD pipelines

## Contribute

The source code for this solution is available at: https://github.com/vyogotech/frappista

We welcome contributions, feedback, and feature requests from the community.

## Conclusion

The Single Node Environment represents our commitment to improving the developer experience in the ERPNext ecosystem. By eliminating setup time and providing a consistent, ready-to-use environment, we hope to boost productivity and lower the barrier to entry for ERPNext development.

We at Vyogo will continue to innovate and provide more features to support the ERPNext community.