import multiprocessing
import time

# This function will run inside a completely separate process
def worker_process(pipe_connection):
    print("[Worker] Process started. Fetching numbers to calculate...")
    
    # 1. Receive the data package from the main process
    data = pipe_connection.recv()
    num1, num2 = data['inputs']
    print(f"[Worker] Received numbers: {num1} and {num2}")
    
    # Simulate doing some work (like a heavy database lookup or math)
    time.sleep(1)
    
    # 2. Perform the computation
    result = num1 + num2
    print(f"[Worker] Computed result: {result}. Sending it back...")
    
    # 3. Send the result back through the pipe
    pipe_connection.send(result)
    
    # Clean up and close the connection
    pipe_connection.close()

if __name__ == "__main__":
    print("[Main] App started on a single CPU core.")
    
    # Create a bidirectional Pipe for Inter-Process Communication (IPC)
    # parent_conn stays with Main, child_conn goes to the Worker
    parent_conn, child_conn = multiprocessing.Pipe()
    
    # Spawn the second process, passing it the communication pipe
    worker = multiprocessing.Process(target=worker_process, args=(child_conn,))
    
    # Start the worker process (the OS gives it a unique Process ID)
    worker.start()
    
    # The Main process prepares the payload
    payload = {'inputs': (10, 3)}
    print(f"[Main] Sending data payload {payload} to the worker process...")
    
    # Main process writes data into the pipe
    parent_conn.send(payload)
    
    # Main process blocks/waits until the worker replies down the pipe
    print("[Main] Waiting for the worker to finish...")
    final_result = parent_conn.recv()
    
    print(f"[Main] Success! Received result from worker: {final_result}")
    
    # Clean up the process completely
    worker.join()
    print("[Main] Program finished.")

