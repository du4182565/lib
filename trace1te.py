import sys
from functools import wraps


def trace_variable(variable_name):
    def decorator(func):
        change_history = []

        def trace(frame, event, arg):
            # value = frame.f_locals.get(variable_name)
            # if value not in change_history:
            #     change_history.append((value))
            print(event, frame.f_code.co_name, frame.f_lineno, frame.f_locals, arg)
            return trace

        @wraps(func)
        def inner(*args, **kwargs):
            sys.settrace(trace)
            result = func(*args, **kwargs)
            sys.settrace(None)
            return result
        return inner
    return decorator


@trace_variable('arr')
def bSort(arr):
    for i in range(len(arr) - 1):
        for j in range(len(arr) - i - 1):
            if arr[j] > arr[j + 1]:
                arr[j], arr[j + 1] = arr[j + 1], arr[j]
    return arr


if __name__ == "__main__":
    arr = [3, 2, 1]
    bSort(arr)
