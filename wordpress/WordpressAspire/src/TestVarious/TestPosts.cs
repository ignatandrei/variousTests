using Microsoft.VisualStudio.TestTools.UnitTesting;
using SqlTableSeparator;
using System.Collections.Generic;
using System.IO;

namespace TestVarious;

[TestClass]
public sealed class TestWordPressTableSeparator
{
    [TestMethod]
    public void Test_WpPostsInsert_TransformAndExtractCategory()
    {
        // Arrange
        var input = "INSERT INTO `wp_posts`(`ID`, `post_author`, `post_date`, `post_date_gmt`, `post_content`, `post_title`, `post_category`, `post_excerpt`, `post_status`, `comment_status`, `ping_status`, `post_password`, `post_name`, `to_ping`, `pinged`, `post_modified`, `post_modified_gmt`, `post_content_filtered`, `post_parent`, `guid`, `menu_order`, `post_type`, `post_mime_type`, `comment_count`) VALUES (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24)";
        var separator = new WordPressTableSeparator();
        var output = separator.RewriteWpPostSql(input);
        // Act
        var shouldBe = "INSERT INTO `wp_posts`(`ID`, `post_author`, `post_date`, `post_date_gmt`, `post_content`, `post_title`, `post_excerpt`, `post_status`, `comment_status`, `ping_status`, `post_password`, `post_name`, `to_ping`, `pinged`, `post_modified`, `post_modified_gmt`, `post_content_filtered`, `post_parent`, `guid`, `menu_order`, `post_type`, `post_mime_type`, `comment_count`) VALUES ('1','2','3','4','5','6','8','9','10','11','12','13','14','15','16','17','18','19','20','21','22','23','24');";

        // Assert
        Assert.AreEqual("1", output.PostId);
        Assert.AreEqual("7", output.PostCategory);
        StringAssert.StartsWith(output.NewInsert, shouldBe);
        StringAssert.StartsWith(output.NewInsert, shouldBe);
    }
}
