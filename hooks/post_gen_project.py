{% if cookiecutter.kind == 'library' -%}
import os

if __name__ == '__main__':
    os.unlink('__main__.py')
{% endif %}
