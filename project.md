${{ content_synopsis }} This image will give you a rootless and lightweight NetBox installation. NetBox exists to empower network engineers. Since its release in 2016, it has become the go-to solution for modeling and documenting network infrastructure for thousands of organizations worldwide. As a successor to legacy IPAM and DCIM applications, NetBox provides a cohesive, extensive, and accessible data model for all things networked. By providing a single robust user interface and programmable APIs for everything from cable maps to device configurations, NetBox serves as the central source of truth for the modern network.

${{ content_uvp }} Good question! All the other images on the market that do exactly the same don’t do or offer these options:

${{ github:> [!IMPORTANT] }}
${{ github:> }}* This image runs as 1000:1000 by default, most other images run everything as root
${{ github:> }}* This image is created via a secure, pinned CI/CD process and immune to upstream attacks, most other images have upstream dependencies that can be exploited
${{ github:> }}* This image contains a proper health check that verifies the app is actually working, most other images have either no health check or only check if a port is open or ping works
${{ github:> }}* This repository has an auto update feature that will automatically build the latest version if released, most other providers don't do this
${{ github:> }}* This image is smaller than most other images

If you value security, simplicity and the ability to interact with the maintainer and developer of an image. Using my images is a great start in that direction.

${{ content_comparison }}

${{ title_volumes }}
* **${{ json_root }}/etc** - Directory of the config.py
* **${{ json_root }}/var** - Directory of reports, uploads and scripts

${{ content_compose }}

${{ content_defaults }}

${{ content_environment }}

${{ content_source }}

${{ content_parent }}

${{ content_built }}

${{ content_tips }}