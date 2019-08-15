import pytest

@pytest.mark.github_cli
def test_github_cli_list_works(host):
    output = host.run('/opt/app/github')
    assert u'You are: anonymous' in output.stdout
    assert output.rc == 0
