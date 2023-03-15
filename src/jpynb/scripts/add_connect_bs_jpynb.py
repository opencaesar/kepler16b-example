import os

def prepend_relative_html_path(file_name: str, string: str):
    """ Prepends HTML path to file. """
    absolute_html_path = os.path.abspath('')
    relative_html_path = file_name
    full_html_path = os.path.join(absolute_html_path, relative_html_path)
    # r+ : - Open for reading and writing. The stream is positioned at the beginning of the file.
    with open(full_html_path, "r") as original:
        data = original.read()
    with open(full_html_path, 'w') as modified:
        modified.write(f"{string}\n" + data)

if __name__ == "__main__":
    prepend_relative_html_path('build/web/index.html', '<a href="./jpynb/kepler16b_reduction.html">Jupyter Notebook</a>')
    prepend_relative_html_path('build/web/jpynb/kepler16b_reduction.html', '<p><a href="../index.html"><u>Bikeshed</u></a></p>')