uint64_t factorial(uint64_t num)
{
    if(num == 0)
    {
        return 1;
    }
    if(num == 1)
    {
        return 1;
    }
    return num * factorial(num - 1);
}

unsigned int uintpow(unsigned int base, unsigned int exp)
{
    unsigned int result = 1;
    while(exp)
    {
        if(exp % 2)
        {
           result *= base;
        }
        exp /= 2;
        base *= base;
    }
    return result;
}

int next_permutation(unsigned int* array, size_t len)
{
    //find largest j such that array[j] < array[j+1]; if no such j then done
    int j = -1;
    for (unsigned int i = 0; i < len - 1; i++)
    {
        if (array[i + 1] > array[i])
        {
            j = i;
        }
    }
    if (j == -1)
    {
        return 0;
    }
    else
    {
        int l;
        for (unsigned int i = j + 1; i < len; i++)
        {
            if (array[i] > array[j])
            {
                l = i;
            }
        }
        unsigned int tmp = array[j];
        array[j] = array[l];
        array[l] = tmp;
        // reverse j + 1 to end
        unsigned int k = (len - 1 - j) / 2; // number of pairs to swap
        for (unsigned int i = 0; i < k; i++)
        {
            tmp = array[j + 1 + i];
            array[j + 1 + i] = array[len - 1 - i];
            array[len - 1 - i] = tmp;
        }
    }
    return 1;
}

