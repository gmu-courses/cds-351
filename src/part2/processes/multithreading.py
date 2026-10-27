import threading
import time

# This function will run inside a separate thread within the same process memory
def worker_thread(data_dict):
    print("[Worker Thread] Thread started. Fetching numbers...")
    
    # Threads can directly read from shared objects like dictionaries
    num1, num2 = data_dict['inputs']
    print(f"[Worker Thread] Received numbers: {num1} and {num2}")
    
    # Simulate an I/O operation or delay
    time.sleep(1)
    
    # Compute and store the result directly into the shared dictionary
    result = num1 + num2
    print(f"[Worker Thread] Computed result: {result}. Storing it...")
    data_dict['result'] = result

if __name__ == "__main__":
    print("[Main] App started.")

    # Shared data structure that both threads can see
    shared_payload = {'inputs': (10, 3), 'result': None}

    # Spawn a new thread, passing it the shared reference
    my_thread = threading.Thread(target=worker_thread, args=(shared_payload,))

    print("[Main] Starting the worker thread...")
    my_thread.start()

    # Main thread blocks/waits until the worker thread completes its work
    print("[Main] Waiting for the thread to finish...")
    my_thread.join()

    # Main can immediately read the result because memory is shared
    print(f"[Main] Success! Retrieved result from shared memory: {shared_payload['result']}")
    print("[Main] Program finished.")

