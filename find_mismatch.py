import sys

def find_mismatch(filename):
    with open(filename, 'r') as f:
        content = f.read()

    open_braces = content.count('{')
    close_braces = content.count('}')
    print(f"Total entries: {{: {open_braces}, }}: {close_braces}")

    stack = []
    for i, char in enumerate(content):
        if char == '{':
            stack.append(i)
        elif char == '}':
            if not stack:
                line_num = content.count('\n', 0, i) + 1
                print(f"Extra '}}' at line {line_num}")
            else:
                stack.pop()
    
    for pos in stack:
        line_num = content.count('\n', 0, pos) + 1
        print(f"Unclosed '{{' at line {line_num}")

if __name__ == "__main__":
    find_mismatch(sys.argv[1])
