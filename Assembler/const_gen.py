NUMBER_OF_BITS_IMM = 4
IMM_RANGE = range(-2**(NUMBER_OF_BITS_IMM - 1), (2**(NUMBER_OF_BITS_IMM - 1)), 1)
REG_SIZE = 16
MAX_UNSIGNED_CONST = (2**REG_SIZE) - 1
MAX_POSITIVE_SIGNED_CONST =  (2**(REG_SIZE - 1)) - 1
MAX_NEGATIVE_SIGNED_CONST = -(2**(REG_SIZE - 1))

def factorate (n):
    i = 1
    factors = []
    while(i <= n):
        k = 0
        if(n % i == 0):
            j = 1
            while(j <= i):
                if(i % j == 0):
                    k = k + 1
                j = j + 1
            if(k == 2):
                factors.append(i)
        i+=1
    return factors

def number_sign (n):
    return (n/abs(n))

def generate_const_tree (imm):
    if imm not in IMM_RANGE:
        raise ValueError
    if imm == 0:
        raise ValueError
    const = abs(imm)
    tree = []
    n = 1
    while(const < MAX_UNSIGNED_CONST):
        if imm < 0:
            tree.append(-const)
        else:
            tree.append(const)
        const = 2**n*abs(imm)
        n+=1
    return tree

def get_all_primes_utill (n):
    primes = [1]
    for i in range(2, max(IMM_RANGE)+1):
        is_prime = True
        for j in range (2, i):
            if i % j == 0:
                is_prime = False
        if is_prime:
            primes.append(i)
    return primes

def find_closest_accumulator (num, accumulator_list):
    mid = int(len(accumulator_list)/2)
    n = abs(num)
    if len(accumulator_list) == 2:
        if n in accumulator_list:
            return int(n)
        elif n > abs(accumulator_list[1]):
            return accumulator_list[1]
        else:
            return accumulator_list[0]
    if n >= abs(accumulator_list[mid]):
        return find_closest_accumulator(n, accumulator_list[mid:])
    else:
        return find_closest_accumulator(n, accumulator_list[:mid+1])

def unroll_const (const):
    if const > 0:
        TRUNCATED_IMM_RANGE = range(1, (2**(NUMBER_OF_BITS_IMM - 1)), 1)
    else:
        TRUNCATED_IMM_RANGE = range(-1, -2**(NUMBER_OF_BITS_IMM - 1) - 1, -1)
    accumulation_trees = {}
    possible_immediate_values = -1
    for value in TRUNCATED_IMM_RANGE:
        possible_immediate_values += 1
        accumulation_trees[value] = []
    while abs(const) > 0:
        closest_accumulator = find_closest_accumulator(const, generate_const_tree(TRUNCATED_IMM_RANGE[possible_immediate_values]))
        while (abs(closest_accumulator) > abs(const)):
            possible_immediate_values -= 1
            closest_accumulator = find_closest_accumulator(const, generate_const_tree(TRUNCATED_IMM_RANGE[possible_immediate_values]))
        accumulation_trees[TRUNCATED_IMM_RANGE[possible_immediate_values]].append(closest_accumulator)
        const = const - closest_accumulator
    return accumulation_trees

if __name__ == "__main__":
    print (unroll_const(-3800))
    print (unroll_const(3800))

# Current progress:
# I get a dict which the keys are the immediates I can use in RISCV16 instructions and the values are lists of which accumulators I need to generate for that immediate.
# For 65535 -> {1: [1], 2: [], 3: [], 5: [], 7: [57344, 7168, 896, 112, 14]}.
#   In this case, when creating 57344, I must checkpoint at 14, 112, 896 and 7168 and save those values into allocated registes.
# Measure sizes...