# kamome/msp

This project is a toy compiler for **Multi-Stage Programming (MSP)**, written in Moonbit. The implementation is heavily inspired by **MetaOCaml** and **Scala-LMS** frameworks.


## Folder Structure

- **`src/`**: Source code for the MSP compiler.
- **`example/`**: Contains example MSP programs as input files.
- **`output/`**: Contains the expected output of the example programs after compilation.


## Usage

To run the compiler on an example MSP file, use the following command:

```bash
moon run src/main -- example/file.msp
```

## Examples

An MSP example file located in [example/power_stage_square.msp](example/power_stage_square.msp) may look like this:


```ocaml
even : (int) => bool = 
  lambda x.
    x % 2 == 0 
      
square : <(int) => int> = 
  lambda x.
    x * x

power : (<int>, int) => <int> = 
  lambda x n.
    if n == 0
      then 1
      else 
        if even(n)
          then square(power(x, n / 2))
          else x * power(x, n - 1)

main : <(int) => int> = 
  lambda input.
    power(input, 13)
```

Run the compiler with the following command:


```bash
moon run src/main -- example/power_stage_square.msp
```

The output will be saved in the [output/power_stage_square_out.msp](output/power_stage_square_out.msp)

```ocaml
square : (int) => int =
  let
    f_1 = lambda x.
      let
        x_0 = (x * x)
      in x_0
  in f_1

main : (int) => int =
  let
    f_7 = lambda input.
      let
        i_0 = 1
        x_1 = (input * i_0)
        x_2 = square(x_1)
        x_3 = (input * x_2)
        x_4 = square(x_3)
        x_5 = square(x_4)
        x_6 = (input * x_5)
      in x_6
  in f_7
```