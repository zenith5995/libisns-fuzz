#include <stddef.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/* Include the headers for the iSNS message API. */
#include "libisns/buffer.h"
#include "libisns/message.h"
#include "libisns/util.h"

int LLVMFuzzerTestOneInput(const uint8_t *Data, size_t Size) {
    if (!Data || Size == 0)
        return 0;

    isns_message_t *msg = calloc(1, sizeof(isns_message_t));
    if (!msg)
        return 0;

    buf_t *payload = buf_alloc(Size + 32);
    if (!payload) {
        free(msg);
        return 0;
    }

    buf_clear(payload);
    if (buf_tailroom(payload) < Size || buf_put(payload, Data, Size) != 0) {
        buf_free(payload);
        free(msg);
        return 0;
    }

    msg->im_payload = payload;

    msg->im_header.i_version = 0x01;
    msg->im_header.i_function = 0x8001;
    msg->im_header.i_length = (uint16_t)Size;

    isns_simple_t *simple = NULL;
    if (isns_simple_decode(msg, &simple) == 0 && simple) {
        // Try re-encoding the decoded message
        isns_message_t *encoded_msg = NULL;
        isns_simple_encode(simple, &encoded_msg);
        if (encoded_msg) {
            isns_message_release(encoded_msg);
        }

        // Try encoding a response based on the decoded message
        isns_message_t *response = NULL;
        isns_simple_encode_response(simple, msg, &response);
        if (response) {
            isns_message_release(response);
        }

        // Try getting objects from the decoded message
        isns_object_list_t objects;
        memset(&objects, 0, sizeof(objects));
        isns_simple_response_get_objects(simple, &objects);

        isns_simple_free(simple);
    }

    isns_message_release(msg);
    return 0;
}
