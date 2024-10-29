# Fire Risk Mapping Tool Considering Weather Conditions and Electric Network Operating Conditions

## Overview

This repository contains a fire risk mapping tool designed to assess fire risks associated with electrical networks under varying weather conditions. It leverages MATPOWER for power system simulations and geospatial analysis to visualize network layouts.

## Requirements

- MATLAB
- MATPOWER

## File Structure

### Code Files

- **Conductor.m**  
  This file defines the properties and behavior of conductor objects used in the simulation. It includes parameters such as weight, resistance, thermal characteristics, and ratings for different conductor types.

- **Environment.m**  
  This file sets up the environmental parameters affecting the conductors' thermal behavior. It includes factors like ambient temperature, wind velocity, and other atmospheric conditions.

- **GUI for WFR.pyw**  
  This is a graphical user interface for receiving weather forecasts. (*Deprecated*)

- **case360.m**  
  This file contains data and configurations for the electrical network simulation. It is essential for running power flow analyses and assessing network performance.

- **plotNetworkBranches.m**  
  This function visualizes the branches of the electrical network. It plots the relationships between different branches, aiding in the analysis of network connectivity and performance.

- **runPowerFlow.m**  
  This script executes power flow simulations using the MATPOWER framework. It computes the state of the network under given load conditions, providing insights into the network's operation.

- **runProgram.m**  
  This script integrates all components of the tool, executing necessary functions and simulations to assess fire risks in the network. It serves as the main entry point for running analyses.

- **tempCalc.m**  
  This function calculates the transient temperature of conductors based on current flow and environmental conditions. It evaluates how temperature varies over time, which is crucial for assessing fire risks.

### Geospatial Plotting

#### Fire-Warning-Mapping-Tool-Considering-Weather-And-Electrical-Network-Conditions

- **/geospatial plot/**

  - **locations.mat**  
    This file contains geographic coordinates for various nodes in the electrical network. These coordinates are essential for plotting the network on a map, allowing for a spatial understanding of the network's layout.

  - **networkData.mat**  
    This file includes detailed data regarding the electrical network, such as bus configurations and interconnections. It is crucial for conducting geospatial analyses and ensuring accurate mapping of the electrical system.

  - **plotNetworkMainLine.m**  
    This function is responsible for visualizing the main line of the electrical network. It utilizes the geographic coordinates from `locations.mat` to create an informative plot that displays the relationships between different network elements.

  - **runProgram.m**  
    This script integrates the geospatial features into the main program. It orchestrates the execution of functions necessary for generating plots and handling network data, facilitating a smooth user experience.

## Usage

To use the tool, ensure you have MATLAB and MATPOWER installed. Load the required data files, execute the main script (`runProgram.m`), and follow the GUI prompts to assess fire risks based on current weather and electrical network conditions.

## Acknowledgments

This tool was developed by Athanasios Tsounakis at the University of Patras, Department of Electrical and Computer Engineering.
