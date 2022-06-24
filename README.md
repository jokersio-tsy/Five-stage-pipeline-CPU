# Five-stage-pipeline-CPU
Five-stage pipeline CPU written in Verilog

The original version was based on lab 4 of the Computer Organization course in Chongqing University.

## principle

Divide the original CPU running cycle into five parts:

- Fetch
- Decode
- Execute
- Memory
- Write back

Use hazard modules to solve data hazard and control hazard problems.(Forward or Stall)



