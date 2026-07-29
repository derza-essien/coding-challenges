# RR Arbiter

### Combinational Logic

- Used to find the next bit in the scheduler that is high
- This is done with a loop which checks if the bit is also above the current prioritised value (`req_ptr`)
- If conditions are met, the lowest priority bit will be selected

### Sequential Logic
- output `grant` is determined by a left shift of the integer 1 by `grant_idx` bits (i.e. the number of bits equal to the lowest priority bit in the comb logic), this only occurs of the requested input is not equal to 0 (otherwise the output is 0)
- the `req_ptr` only resets if the `grant_idx` has reached max value