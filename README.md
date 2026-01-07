# Computational-Ghost-Imaging
# Computational Ghost Imaging (CGI) Simulation

A MATLAB implementation of **Computational Ghost Imaging (CGI)** using the **Differential Ghost Imaging (DGI)** algorithm.

This project simulates the single-pixel imaging process, demonstrating how an image can be reconstructed from a series of random speckle patterns and bucket detector intensity values without spatial resolution.

## 1. Mathematical Principle

The reconstruction is based on the correlation between the bucket detector signal $B_i$ and the illumination patterns $P_i(x,y)$. 

The traditional GI correlation formula is:

$$G(x,y) = \langle B \cdot P(x,y) \rangle - \langle B \rangle \langle P(x,y) \rangle$$

In this simulation, we generate $M$ random binary patterns. The bucket signal $B_i$ for the $i$-th measurement is:

$$B_i = \iint P_i(x,y) \cdot T(x,y) dx dy$$

Where $T(x,y)$ is the transmission function of the object.

## 2. Simulation Results

- **Object Resolution**: 64 x 64 pixels
- **Sampling Ratio**: 5x (Total 20,480 measurements)

![CGI Result](results/cgi_result.png)
*(Left: Ground Truth; Right: Reconstructed Image using DGI)*

## 3. Usage

1. Clone the repository.
2. Run `src/main_cgi.m` in MATLAB.
3. Adjust `M_ratio` in the code to see how sampling rate affects image quality.

---
*Keywords: Single-pixel Imaging, Compressed Sensing, Inverse Problems, MATLAB*
