#include <stddef.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/* Include the headers for the iSNS message API. */
#include "libisns/buffer.h"
#include "libisns/message.h"
#include "libisns/util.h"

/*
 * Fuzz harness entry point for AFL++.
 */
int LLVMFuzzerTestOneInput(const uint8_t *Data, size_t Size) {
    if (Size == 0 || !Data)
        return 0;

    isns_message_t *msg = calloc(1, sizeof(isns_message_t));
    if (!msg)
        return 0;

    // Allocate slightly more space than the input size to be safe
    buf_t *payload = buf_alloc(Size + 32);
    if (!payload) {
        free(msg);
        return 0;
    }

    buf_clear(payload);

    // Make sure we have enough tailroom before writing
    if (buf_tailroom(payload) < Size || buf_put(payload, Data, Size) != 0) {
        buf_free(payload);
        free(msg);
        return 0;
    }

    msg->im_payload = payload;

    // Populate minimal required header
    msg->im_header.i_version = 0x01;
    msg->im_header.i_function = 0x8001;
    msg->im_header.i_length = (uint16_t)Size;

    isns_simple_t *simple = NULL;
    isns_simple_decode(msg, &simple);

    if (simple)
        isns_simple_free(simple);

    isns_message_release(msg);
    return 0;
}
