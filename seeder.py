#!/usr/bin/env python3
import struct

# This example assumes the header format is:
#   version:     1 byte   (B)
#   function:    2 bytes  (H)
#   flags:       2 bytes  (H)
#   length:      4 bytes  (I)   -- payload length
#   xid:         4 bytes  (I)
#   seq:         4 bytes  (I)
#
# The format string "<BHHIII" means:
#  - "<" indicates little-endian byte ordering.
#  - "B" for 1 byte,
#  - "H" for 2 bytes (twice),
#  - "I" for 4 bytes (three times).
#
# This yields a header size of 1 + 2 + 2 + 4 + 4 + 4 = 17 bytes.
# We then add a payload. For a minimal valid message, we can use 4 bytes, for example.
#
# Adjust these values based on what the iSNS parser expects.
version = 1
function = 1         # For example, a registration command, adjust as needed.
flags = 0
payload_length = 4   # Our payload is 4 bytes.
xid = 1
seq = 0

# Pack the header.
header = struct.pack("<BHHIII", version, function, flags, payload_length, xid, seq)
# Create a payload – here just 4 zero bytes.
payload = b"\x00\x00\x00\x00"

# Combine header and payload.
data = header + payload

# Write the resulting binary data to a file.
with open("seed1.bin", "wb") as f:
    f.write(data)

print("Created seed1.bin ({} bytes)".format(len(data)))
