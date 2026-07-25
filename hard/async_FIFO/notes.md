# Async FIFO

### Full condition

The full condition for the async FIFO requires the following

 full =  ( { ~wr_ptr_gray[MSB:MSB-1], wr_ptr_gray[MSB-2:0] } ) == sync_rd_ptr_gray 

This is because of how Gray code conversion is done. Given a FIFO depth of N, the ponters must have a bit length of N+1 where the extra bit becomes a wrap-around bit. When that bit is different to the read pointer, it means the write pointer has wrapped around and then caught up to the read pointer (in a circular buffer type of move).

Given that to convert to gray code for any bit i (that isnt the MSB), you require bit i + 1 in the binary form. Given the MSB would be inverted, the next bit (MSB - 1) which depends on binary MSB for its value in gray code will also be inverted too. As all other bits don't depend on binary MSB, they will stay the same value, hence not being inverted when caught up to

### Empty condition

The empty condition for the async FIFO is as follows:

empty = rd_ptr_gray == sync_wr_ptr_gray

### Other notes

- Remember that gray code of other pointers is required to be passed in a 2-flop synchroniser for metastability
- The gray code pointers must be reset/assigned in the exact same domain (i.e. sync pointers for read in write domain)